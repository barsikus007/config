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

nix_build_and_link() {
  NIX_REPL=$1

  NIX_FILE=$2
  NIX_EVAL=$3
  CONFIG_LOCATION=$4
  CALLBACK=$5

  nix-instantiate --parse "$NIX_FILE" >/dev/null || return
  echo "$NIX_FILE syntax correct"
  echo "eval $NIX_EVAL and build..."
  nix build --file "$NIX_REPL" "$NIX_EVAL" --out-link "$CONFIG_LOCATION" --option substitute false
  echo "Done, exec callback..."
  bash -c "$CALLBACK"
}

nix_home_manager_build_and_link() {
  # TODO: nvd to determine is config changed/changed paths and link
  NIX_REPL=$1

  NIX_FILE=$2
  CALLBACK=$3

  nix-instantiate --parse "$NIX_FILE" >/dev/null || return
  echo "$NIX_FILE syntax correct"
  echo "eval $NIX_EVAL and build..."
  OUT=$(nix build --file "$NIX_REPL" "home.home.activationPackage" --option substitute false --print-out-paths)
  echo "built $OUT"
  sh "$OUT"/bin/home-manager-generation
  echo "Done, exec callback..."
  bash -c "$CALLBACK"
}

nix_hot_reload() {
  NIX_REPL=$1

  NIX_FILE=$2
  NIX_EVAL=$3
  CONFIG_LOCATION=$4
  CALLBACK=$5

  echo "watching with inotifywait: $NIX_FILE"

  while inotifywait -q -e close_write,move,create,delete "$(dirname "$NIX_FILE")" >/dev/null 2>&1; do
    # простой дебаунс
    # если WATCH_PATH файл, то убедимся что он тронут
    if [[ -f "$NIX_FILE" || -d "$WATCH_PATH" ]]; then
      if ! nix_build_and_link $NIX_REPL $NIX_FILE $NIX_EVAL $CONFIG_LOCATION $CALLBACK; then
        echo "build failed; waiting for next change…"
      fi
    fi
  done
}

nix_home_manager_reload() {
  NIX_REPL=/home/ogurez/config/nix/repl.nix

  NIX_FILE="/home/ogurez/config/nix/home"
  CALLBACK="systemctl --user restart noctalia-shell"

  nix_home_manager_build_and_link $NIX_REPL $NIX_FILE $CALLBACK
}

nix_hot_reload_noctalia() {
  NIX_REPL=/home/ogurez/config/nix/repl.nix

  NIX_FILE="/home/ogurez/config/nix/home/desktop/manager/niri/quickshell/noctalia.nix"
  NIX_EVAL='home.xdg.configFile."noctalia/settings.json"'
  CONFIG_LOCATION=/home/ogurez/.config/noctalia/settings.json
  CALLBACK="systemctl --user restart noctalia-shell"

  nix_hot_reload $NIX_REPL $NIX_FILE $NIX_EVAL $CONFIG_LOCATION $CALLBACK
}

nix_hot_reload_niri() {
  NIX_REPL=/home/ogurez/config/nix/repl.nix

  NIX_FILE="/home/ogurez/config/nix/home/gui/niri.nix"
  NIX_EVAL='home.xdg.configFile."niri/config.kdl"'
  CONFIG_LOCATION=/home/ogurez/.config/niri/config.kdl
  CALLBACK=""

  nix_hot_reload $NIX_REPL $NIX_FILE $NIX_EVAL $CONFIG_LOCATION $CALLBACK
}
