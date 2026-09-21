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
  nix-shell --packages "$1" --run "$*"
}

nix_pkgs_only() {
  #? filter a `nix build --dry-run` plan down to real nixpkgs builds,
  #? hiding config glue (etc/hm/unit files, stylix assets, buildEnv) that never lands in the cache
  #? no reliable derivation flag marks glue, so this is a name whitelist: keep name-version, drop config-file extensions
  #? fast by default (uses eval-cache); on a dirty/uncommitted tree the plan may be STALE
  #? pass -f to force a fresh eval (slow, ~1-2 min), or just commit your changes first
  #? usage: nix_pkgs_only [-f] .#nixosConfigurations.ROG14.config.system.build.toplevel
  #? absolute path skips the nix-your-shell function: under --nom the plan never reaches the terminal
  #? the plan goes to stderr; anchoring on .drv keeps the build section, since fetched entries are out paths
  #? one package yields several drv (fhsenv/bwrap/init wrappers, same name under a different hash), so collapse by name
  local opts=()
  [[ $1 == -f ]] && { opts=(--option eval-cache false); shift; }
  /run/current-system/sw/bin/nix build --dry-run "${opts[@]}" "$@" 2>&1 \
    | rg --only-matching --replace '$1' '/nix/store/[a-z0-9]+-(\S+)\.drv' \
    | rg -- '-[0-9]' \
    | rg --invert-match '\.(conf|json|png|css|xml|ini|sh|rules|pl|service|timer|pf2|theme|tar\.gz|tar\.xz|tar\.bz2|tar\.zst|zip)$' \
    | rg --invert-match -- '-env$|initrd-linux|dbus-[0-9]|nixos-system-' \
    | rg --invert-match -- '-(bwrap|init|extracted|vendor|fhsenv-rootfs|fhsenv-profile|modules-shrunk)$' \
    | sort --unique
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
  ldd "$1" | grep 'not found' | awk '{print $1}' | sort --unique | xargs --replace={} sh -c 'echo "Lib: {}"; nix-locate "{}"; echo'
}

nix_build_time_fmt() {
  #? seconds -> "1h 7m 45s", dropping zero high units
  local s=$1
  ((s >= 3600)) && printf '%dh ' $((s / 3600))
  ((s >= 60)) && printf '%dm ' $((s % 3600 / 60))
  printf '%ds' $((s % 60))
}

nix_build_time_medians() {
  #? stdin: "<name> <secs>" lines -> "<median secs> <count> <name>" per name
  sort --key=1,1 --key=2,2n | awk '
    { if ($1 != cur && cur != "") flush(); cur = $1; a[++n] = $2 }
    END { if (cur != "") flush() }
    function flush(  k, m) {
      k = int((n + 1) / 2)
      m = (n % 2) ? a[k] : int((a[k] + a[k + 1]) / 2)
      print m, n, cur
      n = 0
    }'
}

nix_build_time_parse_date() {
  #? date string or shorthand (1w, 7d, 24h, 30m, 10s) -> UTC "YYYY-MM-DD HH:MM:SS"
  local val=$1
  case $val in
    (*[0-9]w) val="${val%w} weeks ago" ;;
    (*[0-9]d) val="${val%d} days ago" ;;
    (*[0-9]h) val="${val%h} hours ago" ;;
    (*[0-9]m) val="${val%m} minutes ago" ;;
    (*[0-9]s) val="${val%s} seconds ago" ;;
  esac
  date --utc --date="$val" '+%F %T' 2>/dev/null
}

nix_build_time() {
  #? build durations measured by nom itself: ~/.local/state/nix-output-monitor/build-reports.csv
  #? keyed by drv name without version, so the history survives rebuilds and drv hash changes
  #? covers only builds that ran through nom; the median is what nom shows as (∅ X) while building
  #? usage: nix_build_time [--since <time>] [--until <time>] <name>...
  #?        nix_build_time [--since <time>] [--until <time>] --top [N]   (default 10)
  #?        nix_build_time --since <time> [--until <time>]
  local csv=${XDG_STATE_HOME:-$HOME/.local/state}/nix-output-monitor/build-reports.csv
  if [[ ! -f $csv ]]; then
    echo "$csv: no such file (nom never recorded a build here)" >&2
    return 1
  fi
  local since="" until="" top=""
  local since_utc="" until_utc=""
  local packages=()
  while [[ $# -gt 0 ]]; do
    case $1 in
      (--since)
        since=$2
        shift 2
        ;;
      (--until)
        until=$2
        shift 2
        ;;
      (--top)
        if [[ -n ${2:-} && $2 =~ ^[0-9]+$ ]]; then
          top=$2
          shift 2
        else
          top=10
          shift 1
        fi
        ;;
      (--)
        shift
        packages+=("$@")
        break
        ;;
      (-*)
        echo "nix_build_time: unknown option: $1" >&2
        return 1
        ;;
      (*)
        packages+=("$1")
        shift
        ;;
    esac
  done
  if [[ -n $since ]]; then
    since_utc=$(nix_build_time_parse_date "$since") || {
      echo "nix_build_time: invalid --since date: $since" >&2
      return 1
    }
    [[ -z $since_utc ]] && {
      echo "nix_build_time: invalid --since date: $since" >&2
      return 1
    }
  fi
  if [[ -n $until ]]; then
    until_utc=$(nix_build_time_parse_date "$until") || {
      echo "nix_build_time: invalid --until date: $until" >&2
      return 1
    }
    [[ -z $until_utc ]] && {
      echo "nix_build_time: invalid --until date: $until" >&2
      return 1
    }
  fi
  if [[ -n $top ]]; then
    #? nom's csv encoder emits CRLF (RFC 4180); without stripping, the last field never parses as a number
    tr --delete '\r' < "$csv" \
      | awk --field-separator=, -v s="$since_utc" -v u="$until_utc" '
          $4 ~ /^[0-9]+$/ && (s == "" || $3 >= s) && (u == "" || $3 <= u) { print $2, $4 }
        ' \
      | nix_build_time_medians \
      | sort --numeric-sort --reverse \
      | head --lines="$top" \
      | while read -r med count name; do
          printf '%s\t%s (%d build%s)\n' "$(nix_build_time_fmt "$med")" "$name" "$count" "$([[ $count -gt 1 ]] && echo s)"
        done
    return
  fi
  if ((${#packages[@]} == 0)); then
    if [[ -z $since_utc && -z $until_utc ]]; then
      echo "usage: nix_build_time [--since <time>] [--until <time>] <package name>... | --top [N]" >&2
      return 1
    fi
    tr --delete '\r' < "$csv" \
      | awk --field-separator=, -v s="$since_utc" -v u="$until_utc" '
          $4 ~ /^[0-9]+$/ && (s == "" || $3 >= s) && (u == "" || $3 <= u)
        ' \
      | sort --field-separator=, --key=3,3 \
      | while IFS=, read -r _ name end secs; do
          printf '%s\t%s\t%s\n' "$(date --date="$end UTC" '+%F %T')" "$(nix_build_time_fmt "$secs")" "$name"
        done
    return
  fi
  local arg matches filtered name end secs med count
  for arg in "${packages[@]}"; do
    matches=$(rg --fixed-strings ",$arg" "$csv") || {
      echo "$arg: no builds recorded by nom" >&2
      continue
    }
    #? nom's csv encoder emits CRLF (RFC 4180); without stripping, the last field never parses as a number
    matches=${matches//$'\r'/}
    filtered=$(printf '%s\n' "$matches" | awk --field-separator=, -v s="$since_utc" -v u="$until_utc" '
      $4 ~ /^[0-9]+$/ && (s == "" || $3 >= s) && (u == "" || $3 <= u)
    ')
    if [[ -z $filtered ]]; then
      echo "$arg: no builds recorded in specified period" >&2
      continue
    fi
    printf '%s\n' "$filtered" | sort --field-separator=, --key=2,2 --key=3,3 | while IFS=, read -r _ name end secs; do
      printf '%s\t%s\t%s\n' "$(date --date="$end UTC" '+%F %T')" "$(nix_build_time_fmt "$secs")" "$name"
    done
    printf '%s\n' "$filtered" | awk --field-separator=, '{print $2, $4}' | nix_build_time_medians | while read -r med count name; do
      printf '∅ %s: %s (%d build%s)\n' "$name" "$(nix_build_time_fmt "$med")" "$count" "$([[ $count -gt 1 ]] && echo s)"
    done
  done
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
  OUT=$(nix build --option substitute false --no-link --print-out-paths "$NIX_EVAL")
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

  while inotifywait --quiet --event close_write,move,create,delete "$(dirname "$NIX_FILE")" >/dev/null 2>&1; do
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

  NIX_FILE="/home/ogurez/config/nix/home/desktop/manager/noctalia-niri.nix"
  NIX_EVAL='home.xdg.configFile."noctalia/settings.json"'
  CONFIG_LOCATION=/home/ogurez/.config/noctalia/settings.json
  CALLBACK="systemctl --user restart noctalia"

  nix_hot_reload $NIX_REPL $NIX_FILE $NIX_EVAL $CONFIG_LOCATION $CALLBACK
}

nix_hot_reload_niri() {
  NIX_REPL=/home/ogurez/config/nix/repl.nix

  NIX_FILE="/home/ogurez/config/nix/home/desktop/manager/niri.nix"
  NIX_EVAL='home.xdg.configFile."niri/config.kdl"'
  CONFIG_LOCATION=/home/ogurez/.config/niri/config.kdl
  CALLBACK=""

  nix_hot_reload $NIX_REPL $NIX_FILE $NIX_EVAL $CONFIG_LOCATION $CALLBACK
}
