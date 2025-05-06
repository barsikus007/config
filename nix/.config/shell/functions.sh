#!/bin/sh

. "$XDG_CONFIG_HOME/shell/setup.sh"
. "$XDG_CONFIG_HOME/shell/wifite.sh"
. "$XDG_CONFIG_HOME/shell/g14.sh"

mkcd() { mkdir -p "$@" && cd "$@" || exit; }
ssht() { (ssh "$@" -t "tmux new -As0 || bash || sh") }

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
