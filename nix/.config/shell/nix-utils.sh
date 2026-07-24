#!/usr/bin/env bash

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

nix_pkgs_only() {
  #? filter a `nix build --dry-run` plan down to real nixpkgs builds,
  #? hiding config glue (etc/hm/unit files, stylix assets, buildEnv) that never lands in the cache
  #? no reliable derivation flag marks glue, so this is a name whitelist: keep name-version, drop config-file extensions
  #? fast by default (uses eval-cache); on a dirty/uncommitted tree the plan may be STALE
  #? pass -f to force a fresh eval (slow, ~1-2 min), or just commit your changes first
  #? usage: nix_pkgs_only [-f] .#nixosConfigurations.ROG14.config.system.build.toplevel
  local opts=()
  [[ $1 == -f ]] && { opts=(--option eval-cache false); shift; }
  nix build --dry-run "${opts[@]}" "$@" 2>&1 \
    | rg -o '/nix/store/[a-z0-9]+-\S+\.drv' \
    | rg -- '-[0-9]' \
    | rg -v '\.(conf|json|png|css|xml|ini|sh|rules|pl|service|timer|pf2|theme)\.drv$' \
    | rg -v -- '-env\.drv$|initrd-linux|dbus-[0-9]|nixos-system-'
}

nix_pkgs_only_host() {
  #? same, targeting the current host toplevel (or pass a hostname: nix_pkgs_only_host KBH)
  #? -f forwards the fresh-eval flag: nix_pkgs_only_host -f [hostname]
  local fresh=()
  [[ $1 == -f ]] && { fresh=(-f); shift; }
  nix_pkgs_only "${fresh[@]}" "${NH_FLAKE:-.}#nixosConfigurations.${1:-$HOST}.config.system.build.toplevel"
}

nix_copy_edit() {
  #? fd -H '\.lnk$'
  mv "$1" "$1.lnk"
  cp --no-preserve=mode,ownership "$1.lnk" "$1"
  nvim "$1"
}

nix_find_libs() {
  ldd "$1" | grep 'not found' | awk '{print $1}' | sort -u | xargs -I {} sh -c 'echo "Lib: {}"; nix-locate "{}"; echo'
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

nix_home_manager_build_and_activate() {
  local NIX_EVAL="$NH_FLAKE#nixosConfigurations.$HOST.config.home-manager.users.$USER.home.activationPackage"
  echo "building $NIX_EVAL..."
  OUT=$(nom build --option substitute false --no-link --print-out-paths "$NIX_EVAL")
  echo "built $OUT"
  #? mirror _nn: pick specialisation from darkman theme
  local ACTIVATE="$OUT/activate"
  if [ -f ~/.cache/darkman/mode.txt ]; then
    echo "Current theme is: $(cat ~/.cache/darkman/mode.txt)"
    case "$(cat ~/.cache/darkman/mode.txt)" in
      ("light") ACTIVATE="$OUT/specialisation/light/activate" ;;
    esac
  else
    echo "No theme file found"
  fi
  "$ACTIVATE"
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
        echo "build failed; waiting for next change..."
      fi
    fi
  done
}

nix_home_manager_reload() {
  NIX_REPL=/home/ogurez/config/nix/repl.nix

  NIX_FILE="/home/ogurez/config/nix/home"
  CALLBACK="systemctl --user restart noctalia"

  nix_home_manager_build_and_link $NIX_REPL $NIX_FILE $CALLBACK
}

nix_hot_reload_noctalia() {
  NIX_REPL=/home/ogurez/config/nix/repl.nix

  NIX_FILE="/home/ogurez/config/nix/home/desktop/manager/niri/quickshell/noctalia.nix"
  NIX_EVAL='home.xdg.configFile."noctalia/settings.json"'
  CONFIG_LOCATION=/home/ogurez/.config/noctalia/settings.json
  CALLBACK="systemctl --user restart noctalia"

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
