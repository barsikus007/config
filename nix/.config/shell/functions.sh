#!/bin/bash

. "$XDG_CONFIG_HOME/shell/setup.sh"
. "$XDG_CONFIG_HOME/shell/android-utils.sh"
. "$XDG_CONFIG_HOME/shell/g14.sh"
. "$XDG_CONFIG_HOME/shell/wifite.sh"

mkcd() { mkdir -p "$@" && cd "$@" || exit; }

batman() {
    BAT_THEME="Solarized (dark)" \command batman "$@"
    return $?
}

ssht() {
  (
    case "$1" in
      -*) echo "Specify hostname first"; return 1 ;;
    esac
    ssh "$@" -t "zellij attach -c $1 options --default-mode locked --session-serialization false || tmux new -As$1 || bash || sh"
  )
}

dcsh() { docker compose exec -it "$1" sh -c 'bash || sh'; }

a() {
  # shellcheck disable=SC2046
  print -z -- $(
    alias | awk -F= '{print $1}' |
    fzf --height 40% --border --prompt="Alias: " \
        --preview "zsh  -c 'source ~/.zshrc && alias {} | cut -d= -f2-' | tr -d \' | bat -l sh --style=plain --color=always" \
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

type_colored() {
  type -afs "$@" | sed 's/is an alias for/is an alias for:\n/' | bat -l sh --style=plain --color=always
}

type_colored_and_nix_truncate() {
  type_colored "$@" | nix_truncate
}

nix_truncate() {
  (
    # nix_store_regex='\(\/nix\/store\/[a-z0-9]\{32\}-\([^[:space:]]*\)\)'
    nix_store_regex='\(\/nix\/store\/[a-z0-9]\{32\}-\([^\/]*\)\)'
    underline=$(tput smul)
    reset=$(tput sgr0)
    osc8_start=$'\e]8;;file://'
    osc8_mid=$'\e\\\\'
    osc8_end=$'\e]8;;\e\\'
    # sed "s|${nix_store_regex}|${underline}\2${reset}|g"
    sed "s|${nix_store_regex}|${underline}${osc8_start}\1${osc8_mid}\2${osc8_end}${reset}|g"
  )
}

nix_shell_exec() {
  nix-shell -p "$1" --run "$*"
}

export_aliases() {  # TODO WIP
  # export aliases
  # alias | awk -F'[ =]' '{print "alias "$2"='\''"$3"'\''"}'
  alias | sed -z 's/\n/\&\&/g' | sed -e 's/[^(alias)] /\\\\ /g'
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
