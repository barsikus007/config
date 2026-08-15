{
  lib,
  pkgs,
  config,
  defaultSession,
}:
let
  isNiri = defaultSession == "niri";
  isKDE = defaultSession == "plasma";

  niri = lib.getExe config.programs.niri.package;
  kdotool = lib.getExe' pkgs.kdotool "kdotool";
  wl-copy = lib.getExe' pkgs.wl-clipboard "wl-copy";
  spectacle = lib.getExe pkgs.kdePackages.spectacle;
  btop = lib.getExe pkgs.btop;
  grim = lib.getExe pkgs.grim;
  jq = lib.getExe pkgs.jq;
  libnotify = lib.getExe pkgs.libnotify;
  slurp = lib.getExe pkgs.slurp;
  tesseract = lib.getExe pkgs.tesseract;
  wezterm = lib.getExe pkgs.wezterm;
  xprop = lib.getExe pkgs.xprop;
in
[
  (pkgs.writeShellScriptBin "get-focused-window-pid" (
    (
      if isNiri then
        /* shell */ ''
          PID=$(${niri} msg --json focused-window | ${jq} '.pid')
          #? jq prints "null" when nothing is focused, which slips past -z
          [ "$PID" = "null" ] && PID=""

          #! niri reports the xwayland-satellite pid for every X11 window,
          #! acting on it hits the X server instead of the app
          #? match on exe, not comm: the kernel truncates comm to 15 chars
          #? and the nix wrapper turns it into ".xwayland-satel"
          case "$(readlink --canonicalize /proc/"$PID"/exe 2>/dev/null)" in
            *xwayland-satellite* | *Xwayland*)
              export DISPLAY=''${DISPLAY:-:0}
              WINDOW_ID=$(${xprop} -root _NET_ACTIVE_WINDOW | grep --only-matching '0x[0-9a-f]*')
              PID=$(${xprop} -id "$WINDOW_ID" _NET_WM_PID | grep --only-matching '[0-9]*$')
              #? a containerized client may report a pid that does not exist on the host
              if [ -z "$PID" ] || [ ! -d /proc/"$PID" ]; then PID=""; fi
              ;;
          esac
        ''
      else if isKDE then
        /* shell */ ''
          WINDOW_ID=$(${kdotool} getactivewindow)
          if [ -z "$WINDOW_ID" ]; then
            ${libnotify} "Error" "No valid window ID obtained. Did you focus a window?" --urgency=critical
            exit 1
          fi
          PID=$(${kdotool} getwindowpid "$WINDOW_ID")
        ''
      else
        /* shell */ ''
          PID=""
        ''
    )
    + /* shell */ ''
      echo $PID
    ''
  ))
  (pkgs.writeShellScriptBin "inspect-window" /* shell */ ''
    PID=$(get-focused-window-pid)
    if [ -z "$PID" ]; then
      ${libnotify} "Error" "No valid PID obtained. Did you focus a window?" --urgency=critical
      exit 1
    fi

    ${wezterm} start --always-new-process -- ${btop} --filter "$PID"
  '')
  (pkgs.writeShellScriptBin "kill-focused-window-pid" (
    /* shell */ ''
      PID=$(get-focused-window-pid)
      if [ -z "$PID" ]; then
        ${libnotify} "Error" "No valid PID obtained. Did you focus a window?" --urgency=critical
        exit 1
      fi
    ''
    + lib.optionalString isNiri /* shell */ ''
      #? both lookups need the window still focused, so resolve before closing it
      WINDOW_ID=$(${niri} msg --json focused-window | ${jq} '.id')
      ${niri} msg action close-window

      #! one pid often backs several windows (wezterm, firefox, code),
      #! so fall back to killing the process only when the app ignores the close request
      for _ in $(seq 20); do
        ${niri} msg --json windows \
          | ${jq} --exit-status --argjson id "$WINDOW_ID" 'any(.[]; .id == $id)' >/dev/null 2>&1 || exit 0
        sleep 0.1
      done

      #? past here the app ignored the close request; count what the kill would take down
      N=$(${niri} msg --json windows | ${jq} --argjson p "$PID" '[.[] | select(.pid == $p)] | length')
      if [ "$N" -gt 1 ]; then
        COMMAND_NAME=$(cat /proc/"$PID"/comm 2>/dev/null)
        ACTION=$(${libnotify} "Force close" "Process $PID ($COMMAND_NAME) holds $N windows" \
          --urgency=critical --wait --action=kill="Kill all $N windows" 2>/dev/null)
        [ "$ACTION" = "kill" ] || exit 0
      fi
    ''
    + /* shell */ ''
      kill "$PID"
    ''
  ))
  (pkgs.writeShellScriptBin "slurp-grim-screenshot" /* shell */ ''
    ${grim} -g "$(${slurp})" -l 0 - | ${wl-copy}
  '')
  #! https://github.com/niri-wm/niri/pull/3316
  (pkgs.writeShellScriptBin "niri-toggle-touchpad" /* shell */ ''
    state=
    for name in /sys/class/input/input*/name; do
      grep --quiet --ignore-case touchpad "$name" || continue
      file="$(dirname "$name")/inhibited"
      [ -w "$file" ] || {
        ${libnotify} --urgency critical --app-name niri "Cannot write $file (udev rule / input group?)"
        exit 1
      }
      #? derive the target state once, then apply it to every touchpad node
      [ -z "$state" ] && { [ "$(cat "$file")" = 1 ] && state=0 || state=1; }
      echo "$state" > "$file"
    done
    if [ -z "$state" ]; then
      ${libnotify} --urgency critical --app-name niri "No touchpad found"
      exit 1
    fi
    [ "$state" = 1 ] \
      && ${libnotify} --app-name niri "Touchpad disabled" \
      || ${libnotify} --app-name niri "Touchpad enabled"
  '')
  (pkgs.writeShellScriptBin "ocr-screen-region" (
    if isKDE then
      /* shell */ ''
        SCREENSHOT=$(mktemp)
        ${spectacle} --background --nonotify --region --output $SCREENSHOT && ${tesseract} -l eng+rus $SCREENSHOT stdout | ${wl-copy}
        rm $SCREENSHOT
      ''
    else
      /* shell */ ''
        ${grim} -g "$(${slurp})" - | ${tesseract} -l eng+rus - stdout | ${wl-copy}
      ''
  ))
]
