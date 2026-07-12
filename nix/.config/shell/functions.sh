#!/usr/bin/env bash

mkcd() { mkdir -p "$@" && cd "$@" || exit; }

ssht() {
  (
    case "$1" in
      (-*) echo "Specify hostname first"; return 1 ;;
    esac
    ssh "$@" -t "zellij attach -c $1 options --default-mode locked --session-serialization false || tmux new -As$1 || bash || sh"
  )
}

a() {
  # shellcheck disable=SC2046
  print -z -- $(
    alias | awk -F= '{print $1}' |
    fzf --height 40% --border --prompt="Alias: " \
        --preview "zsh  -c 'source ~/.config/zsh/.zshrc && alias {} | cut --delimiter== --fields=2-' | tr --delete \' | bat --language sh --style=plain --color=always" \
        --preview-window 80%
  )
}

s () {
  #? https://dev.to/kaeruct/fzf-ssh-config-hosts-23dj
  (
    server=$(grep -E '^Host ' ~/.ssh/config | awk '{print $2}' | fzf --height 40%)
    if [[ -n $server ]]; then
      echo "Connecting to $server..."
      ssht "$server" "$@"
    fi
  )
}

ds() {
  # Starts fzf in phony mode (ignores internal filtering)
  # and reloads the danksearch query on every keystroke.
  fzf --phony \
      --prompt="DankSearch> " \
      --bind "change:reload(dsearch search {q} --limit 100 --json | jq -r '.hits[].id' || true)" \
      --preview 'bat --color=always --style=numbers,changes --line-range :500 {}' \
      --preview-window="right:60%:border-left" \
      --layout=reverse \
      --info=inline
}

capture_wezterm_zsh_cmd() {
  # Time limit in seconds: how long to let the command run before screenshotting.
  # Short commands are captured as soon as they finish; interactive/never-exiting
  # apps (htop, vim, ...) are captured once this elapses. Bump it for slow commands.
  local timeout=3
  # optional leading -t/--timeout N; everything after is the command, so
  # multi-word invocations work unquoted (e.g. capture_wezterm_zsh_cmd cat ~/smth)
  while [[ "$1" == -* ]]; do
    case "$1" in
      (-t|--timeout) timeout="$2"; shift 2 ;;
      (*) echo "Unknown option: $1"; return 1 ;;
    esac
  done
  local cmd="$*"

  if [[ -z "$cmd" ]]; then
    echo "Error: no command given."
    return 1
  fi

  if ! command -v tmux >/dev/null 2>&1; then
    echo "Error: tmux is required to measure the 2D geometry."
    return 1
  fi

  echo "Rendering output in tmux (command runs exactly once)..."

  local session="wez_measure_$$"
  local dump_colored="/tmp/wez_dump_$$.ansi"
  local done_file="/tmp/wez_done_$$"

  # 1. Launch tmux in the background (it provides a real pty).
  # zsh -i loads the interactive config (aliases, functions, colors, the real
  # PS1), prints the actual prompt + command and runs it exactly once; inside a
  # pty the zle/precmd hooks work without errors and eval expands aliases.
  # The command and the marker path go through the session environment (-e):
  # this avoids quote-escaping headaches and does not leak variables into the
  # parent shell. When the command finishes it creates the marker file, then the
  # session sleeps so we still have time to grab the screen.
  tmux new-session -d -s "$session" -x 240 -y 80 \
    -e "CMD_TO_RUN=$cmd" -e "DONE_FILE=$done_file" \
    'zsh -i -c '\''print -Pn "$PS1"; echo " $CMD_TO_RUN"; eval "$CMD_TO_RUN"; touch "$DONE_FILE"; sleep 600'\'''

  # 2. Wait until the command finishes OR the time limit elapses, whichever comes
  # first. Interactive apps never create the marker, so the limit is what lets us
  # screenshot them after they have rendered.
  local deadline=$(( SECONDS + timeout ))
  while [[ ! -f "$done_file" ]]; do
    (( SECONDS >= deadline )) && break
    sleep 0.1
  done
  rm -f "$done_file"

  # 3. Plain-text screen dump, used only to measure the geometry.
  local screen_dump=$(tmux capture-pane -p -t "$session")

  # Last non-empty line number - trims the empty blackness at the bottom.
  local rows=$(echo "$screen_dump" | awk '/[^[:space:]]/{last=NR} END{print last}')
  local cols=$(echo "$screen_dump" | wc -L)

  [[ -z "$rows" || "$rows" == "0" ]] && rows=1

  # Single padding knob (in cells), needed for two reasons:
  #  - a space-only line is treated as empty by awk, yet in the colored dump it
  #    may carry a background fill - without slack such lines get clipped;
  #  - a margin around the text so it does not touch the window edges.
  local pad=4

  # 4. Colored dump. tmux numbers lines from 0, so the last content line is
  # (rows-1); we add `pad` lines of slack below it.
  tmux capture-pane -e -p -t "$session" -S 0 -E $((rows - 1 + pad)) > "$dump_colored"

  # Kill tmux - no longer needed.
  tmux kill-session -t "$session" 2>/dev/null

  # Window geometry = content + the same margin on each side.
  rows=$((rows + pad))
  cols=$((cols + pad))

  # [[ $rows -lt 5 ]] && rows=5
  # [[ $cols -lt 40 ]] && cols=40
  # [[ $rows -gt 60 ]] && rows=60
  # [[ $cols -gt 240 ]] && cols=240

  echo "Chosen size: $cols columns, $rows rows. Launching WezTerm..."

  # 5. Open WezTerm. Instead of running the command, it just prints the colored
  # dump and waits 2 seconds.
  wezterm \
    --config initial_cols=$cols \
    --config initial_rows=$rows \
    start --always-new-process --class org.wezfurlong.wezterm.floating \
    -- zsh -c "cat \"$dump_colored\"; sleep 2; rm -f \"$dump_colored\"" &

  # Give the window manager time to draw the window.
  sleep 2

  # 6. Screenshot.
  if [[ "$XDG_CURRENT_DESKTOP" == *"KDE"* ]]; then
    spectacle -a -b
    echo "Window screenshot (KDE) saved."

  elif command -v niri >/dev/null 2>&1; then
    niri msg action screenshot-window
    echo "Window screenshot (Niri) taken."

  else
    grim ~/Pictures/Screenshots/wezterm_exec_$(date +%Y%m%d_%H%M%S).png
    echo "Screenshot taken via grim."
  fi
}

type_colored() {
  type -afs "$@" | sed 's/is an alias for/is an alias for:\n/' | bat -l sh --style=plain --color=always
}

# ripgrep->fzf->vim [QUERY]
rfv() (
  # https://junegunn.github.io/fzf/tips/ripgrep-integration/
  RELOAD='reload:rg --column --color=always --smart-case {q} || :'
  # shellcheck disable=SC2016
  OPENER='if [[ $FZF_SELECT_COUNT -eq 0 ]]; then
            vim {1} +{2}     # No selection. Open the current line in Vim.
          else
            vim +cw -q {+f}  # Build quickfix list for the selected items.
          fi'
  fzf --disabled --ansi --multi \
      --bind "start:$RELOAD" --bind "change:$RELOAD" \
      --bind "enter:become:$OPENER" \
      --bind "ctrl-o:execute:$OPENER" \
      --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
      --delimiter : \
      --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
      --preview-window '~4,+{2}+4/3,<80(up)' \
      --query "$*"
)


smb_trash() {
  fd --hidden --no-ignore \
    --regex '^(\._.*|\.apdisk|\.AppleDouble|\.DS_Store|\.TemporaryItems|\.Trashes|desktop\.ini|ehthumbs\.db|Network Trash Folder|Temporary Items|Thumbs\.db)$' \
    "${@:-.}"  # args or . if none
}

zcd() {
  local current_dir
  current_dir=$(pwd)

  # 1. Get the dataset name from the first column of df
  dataset=$(df -P "$current_dir" | awk 'NR==2 {print $1}')

  # Verify it is actually a ZFS dataset
    if ! zfs list "$dataset" >/dev/null 2>&1; then
        echo "Error: Filesystem '$dataset' is not recognized as a ZFS dataset."
        return 1
    fi

  # 2. Check its mountpoint via zfs get
  local zfs_mountroot=$(zfs get -H -o value mountpoint "$dataset")

  # Handle cases where ZFS delegates mounting (e.g., fstab)
  if [[ "$zfs_mountroot" == "legacy" || "$zfs_mountroot" == "none" ]]; then
    zfs_mountroot=$(df -P "$current_dir" | awk 'NR==2 {print $6}')
  fi

  local snap_dir="${zfs_mountroot%/}/.zfs/snapshot"

  if [ ! -d "$snap_dir" ]; then
    echo "Error: No ZFS snapshots found for this dataset at $snap_dir."
    return 1
  fi

  # Calculate the path relative to the mountpoint
  local rel_path="${current_dir#"$mnt_point"}"
  rel_path="${rel_path#/}" # Remove leading slash

  # Select snapshot using fzf
  local selected_snap=$(\command ls -1 "$snap_dir" | fzf --prompt="Select ZFS Snapshot: ")

  if [ -z "$selected_snap" ]; then
    return 0
  fi

  local target_dir="$snap_dir/$selected_snap/$rel_path"

  if [ -d "$target_dir" ]; then
    cd "$target_dir" || return 1
    echo "Moved to snapshot: $selected_snap"
  else
    echo "Error: This directory does not exist in the selected snapshot."
    return 1
  fi
}

desc() {  # TODO WIP
  # TODO warp all funcs with ()
  (
    sudo=false
    command=$1
    i=3
    if [ "$command" = "-" ]; then
      command=""
      for arg in "$@"; do
        [ "$arg" = "-" ] && [ "$command" != "" ] && break
        [ "$arg" = "-" ] && continue
        i=$((i + 1))
        command="$command $arg"
      done
    elif [ "$command" = "sudo" ]; then
      sudo=true
      command=$2
      echo 123
    fi
    echo "$command" "${@:$i}"
    echo "$command --help"
    help=$($command --help)
    for arg in "${@:$i}"; do
      if [[ "$arg" = -* ]]; then
        echo "$help" | grep --regexp=" $arg[, ]" -
      else
        echo "$arg"
      fi
    done
    # [[ "$URL" == "$PATTERN"* ]]
  )
}

desksort() {
  #? tidy ~/.local/share/applications: move matching *.desktop into category subdirs
  #? cosmetic only - XDG scans the dir recursively, so menu/launcher entries stay the same
  #? usage:
  #?   desksort                      # apply built-in rules below
  #?   desksort <regex> <category>   # move files whose body matches <regex> into <category>/
  #?   desksort -n ...               # dry-run, only print what would move
  (
    local apps="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
    local dry=0
    [[ $1 == -n || $1 == --dry-run ]] && { dry=1; shift; }
    [[ -d $apps ]] || { echo "no such dir: $apps"; return 1; }

    # move every top-level *.desktop whose body matches $1 into subdir $2
    move_rule() {
      local file
      rg --files-with-matches --max-depth 1 --glob '*.desktop' --regexp "$1" "$apps" 2>/dev/null |
      while IFS= read -r file; do
        if (( dry )); then
          echo "would move: ${file##*/} -> $2/"
        else
          mkdir --parent "$apps/$2"
          mv --no-clobber --verbose "$file" "$apps/$2/"
        fi
      done
    }

    if [[ -n $1 ]]; then
      #! manual mode: explicit pattern + target subdir
      move_rule "$1" "${2:?usage: desksort [-n] <regex> <category>}"
    else
      #! built-in rules, first match wins (once moved into a subdir it drops out of the top-level scan)
      move_rule '^Exec=steam'    steam
      move_rule '^Exec=.*wine'   wine
      move_rule '^Exec=waydroid' waydroid
    fi
  )
}
