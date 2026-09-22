#!/usr/bin/env bash

mkcd() { mkdir --parents "$@" && cd "$@" || exit; }

ssht() {
  (
    case "$1" in
      (-*) echo "Specify hostname first"; return 1 ;;
    esac
    ssh "$@" -t "zellij attach --create $1 options --default-mode locked --session-serialization false --theme blade-runner || tmux new -As$1 || bash || sh"
  )
}

a() {
  # shellcheck disable=SC2046
  print -z -- $(
    alias | awk --field-separator='=' '{print $1}' |
    fzf --height 40% --border --prompt="Alias: " \
        --preview "zsh  -c 'source ~/.config/zsh/.zshrc && alias {} | cut --delimiter== --fields=2-' | tr --delete \' | bat --language sh --style=plain --color=always" \
        --preview-window 80%
  )
}

s () {
  #? https://dev.to/kaeruct/fzf-ssh-config-hosts-23dj
  (
    server=$(grep --extended-regexp '^Host ' ~/.ssh/config | awk '{print $2}' | fzf --height 40%)
    if [[ -n $server ]]; then
      echo "Connecting to $server..."
      ssht "$server" "$@"
    fi
  )
}

ds() {
  # starts fzf in phony mode (ignores internal filtering)
  # and reloads the danksearch query on every keystroke
  # enter replaces fzf with xdg-open, alt-enter opens and keeps searching

  # vicinae file search requires at least 3 characters
  fzf --phony \
      --prompt="Vicinae> " \
      --bind "change:reload(vicinae fs query {q} --limit 100 2>/dev/null || true)" \
      --bind 'enter:become(xdg-open {})' \
      --bind 'alt-enter:execute-silent(xdg-open {})' \
      --preview 'bat --color=always --style=numbers,changes --line-range :500 {}' \
      --preview-window="right:60%:border-left" \
      --layout=reverse \
      --info=inline
}

clone() {
  #? usage: clone <url> [dir]
  #? pass the target dir to git explicitly, otherwise cd has to guess where the clone landed
  local url=${1%/}
  local dir=${2:-}
  if [ -z "$dir" ]; then
    #? strip host/user prefix: works for both scp-like git@host:user/repo.git and https urls
    dir=${url##*[:/]}
    dir=${dir%.git}
  fi
  git clone --depth=1 "$url" "$dir" && cd "$dir" || return
}

adbfs_yazi() {
  local target
  target=$(adbfs_connect "$@") || return 1
  [[ -n "$target" ]] && y "$target"
}

type_colored() {
  type -afs "$@" | sed 's/is an alias for/is an alias for:\n/' | bat --language sh --style=plain --color=always
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

  # 1. get the dataset name from the first column of df
  dataset=$(df --portability "$current_dir" | awk 'NR==2 {print $1}')

  # verify it is actually a ZFS dataset
    if ! zfs list "$dataset" >/dev/null 2>&1; then
        echo "Error: Filesystem '$dataset' is not recognized as a ZFS dataset."
        return 1
    fi

  # 2. check its mountpoint via zfs get
  local zfs_mountroot=$(zfs get -H -o value mountpoint "$dataset")

  # handle cases where ZFS delegates mounting (e.g., fstab)
  if [[ "$zfs_mountroot" == "legacy" || "$zfs_mountroot" == "none" ]]; then
    zfs_mountroot=$(df --portability "$current_dir" | awk 'NR==2 {print $6}')
  fi

  local snap_dir="${zfs_mountroot%/}/.zfs/snapshot"

  if [ ! -d "$snap_dir" ]; then
    echo "Error: No ZFS snapshots found for this dataset at $snap_dir."
    return 1
  fi

  # calculate the path relative to the mountpoint
  local rel_path="${current_dir#"$zfs_mountroot"}"
  rel_path="${rel_path#/}" # Remove leading slash

  # select snapshot using fzf
  local selected_snap=$(\command ls --format=single-column "$snap_dir" | fzf --prompt="Select ZFS Snapshot: ")

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

    #? move every top-level *.desktop whose body matches $1 into subdir $2
    move_rule() {
      local file
      rg --files-with-matches --max-depth 1 --glob '*.desktop' --regexp "$1" "$apps" 2>/dev/null |
      while IFS= read -r file; do
        if (( dry )); then
          echo "would move: ${file##*/} -> $2/"
        else
          mkdir --parents "$apps/$2"
          mv --no-clobber --verbose "$file" "$apps/$2/"
        fi
      done
    }

    if [[ -n $1 ]]; then
      #? manual mode: explicit pattern + target subdir
      move_rule "$1" "${2:?usage: desksort [-n] <regex> <category>}"
    else
      #? built-in rules, first match wins (once moved into a subdir it drops out of the top-level scan)
      move_rule '^Exec=steam'    steam
      move_rule '^Exec=.*wine'   wine
      #! this is blindly recreates at boot
      # move_rule '^Exec=waydroid' waydroid
    fi
  )
}
