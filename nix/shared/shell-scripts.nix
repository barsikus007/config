{ pkgs, ... }:
#! TODO: made it DE independent: lib.getExe niri,kdotool,lib.getExe kdePackages.spectacle
with pkgs;
[
  (writeShellScriptBin "get-focused-window-pid" /* shell */ ''
    if [ "$XDG_CURRENT_DESKTOP" = "niri" ]; then
      PID=$(niri msg --json focused-window | ${lib.getExe jq} '.pid')
    elif [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
      WINDOW_ID=$(${kdotool}/bin/kdotool getactivewindow)
      if [ -z "$WINDOW_ID" ]; then
        ${lib.getExe libnotify} "Error" "No valid window ID obtained. Did you focus a window?" --urgency=critical
        exit 1
      fi
      PID=$(kdotool getwindowpid "$WINDOW_ID")
    else
      PID=""
    fi

    echo $PID
  '')
  (writeShellScriptBin "inspect-window" /* shell */ ''
    PID=$(get-focused-window-pid)
    if [ -z "$PID" ]; then
      ${lib.getExe libnotify} "Error" "No valid PID obtained for window ID $WINDOW_ID." --urgency=critical
      exit 1
    fi

    ${lib.getExe wezterm} start --always-new-process -- ${lib.getExe btop} --filter "$PID"
  '')
  (writeShellScriptBin "slurp-grim-screenshot" /* shell */ ''
    ${lib.getExe grim} -g "$(${lib.getExe slurp})" -l 0 - | ${pkgs.wl-clipboard}/bin/wl-copy
  '')
  #! https://github.com/niri-wm/niri/pull/3316
  (writeShellScriptBin "niri-toggle-touchpad" /* shell */ ''
    state=
    for name in /sys/class/input/input*/name; do
      grep -qi touchpad "$name" || continue
      file="$(dirname "$name")/inhibited"
      [ -w "$file" ] || {
        ${lib.getExe libnotify} -u critical -a niri "Cannot write $file (udev rule / input group?)"
        exit 1
      }
      #? derive the target state once, then apply it to every touchpad node
      [ -z "$state" ] && { [ "$(cat "$file")" = 1 ] && state=0 || state=1; }
      echo "$state" > "$file"
    done
    if [ -z "$state" ]; then
      ${lib.getExe libnotify} -u critical -a niri "No touchpad found"
      exit 1
    fi
    [ "$state" = 1 ] \
      && ${lib.getExe libnotify} -a niri "Touchpad disabled" \
      || ${lib.getExe libnotify} -a niri "Touchpad enabled"
  '')
  (writeShellScriptBin "ocr-screen-region" /* shell */ ''
    if [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
      SCREENSHOT=$(mktemp)
      spectacle --background --nonotify --region --output $SCREENSHOT && ${lib.getExe tesseract} -l eng+rus $SCREENSHOT stdout | ${wl-clipboard}/bin/wl-copy
      rm $SCREENSHOT
    else
      ${lib.getExe grim} -g "$(${lib.getExe slurp})" - | ${lib.getExe pkgs.tesseract} -l eng+rus - stdout | ${pkgs.wl-clipboard}/bin/wl-copy
    fi
  '')
]
