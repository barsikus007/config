#!/bin/bash

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

nix_copy_edit() {
  #? fd -H '\.lnk$'
  mv "$1" "$1.lnk"
  cp --no-preserve=mode,ownership "$1.lnk" "$1"
  nvim "$1"
}

_nn() {
  if [ -f ~/.cache/darkman/mode.txt ]; then
    echo "Current theme is: $(cat ~/.cache/darkman/mode.txt)"
    case "$(cat ~/.cache/darkman/mode.txt)" in
      ("dark") nh os switch "$@" ;;
      ("light") nh os switch --specialisation=light "$@" ;;
      (*) nh os switch "$@" ;;
    esac
  else
    echo "No theme file found"
    nh os switch "$@"
  fi
}

nnn() {
  sudo true && _nn "$@" && notify-send 'System build success' && exec $SHELL || notify-send 'System build failed'
}
