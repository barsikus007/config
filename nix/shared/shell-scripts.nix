{ pkgs, ... }:
with pkgs;
[
  (writeShellScriptBin "get-focused-window-pid" ''
    if [ "$XDG_CURRENT_DESKTOP" = "niri" ]; then
      PID=$(${lib.getExe niri} msg --json focused-window | ${lib.getExe jq} '.pid')
    elif [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
      WINDOW_ID=$(${kdotool}/bin/kdotool getactivewindow)
      if [ -z "$WINDOW_ID" ]; then
        ${lib.getExe libnotify} "Error" "No valid window ID obtained. Did you focus a window?" --urgency=critical
        exit 1
      fi
      PID=$(${kdotool}/bin/kdotool getwindowpid "$WINDOW_ID")
    else
      PID=""
    fi

    echo $PID
  '')
  (writeShellScriptBin "inspect-window" ''
    PID=$(get-focused-window-pid)
    if [ -z "$PID" ]; then
      ${lib.getExe libnotify} "Error" "No valid PID obtained for window ID $WINDOW_ID." --urgency=critical
      exit 1
    fi

    ${lib.getExe wezterm} start --always-new-process -- ${lib.getExe btop} --filter "$PID"
  '')
  (writeShellScriptBin "slurp-grim-screenshot" ''
    ${lib.getExe grim} -g "$(${lib.getExe slurp})" -l 0 - | ${pkgs.wl-clipboard}/bin/wl-copy
  '')
  (writeShellScriptBin "ocr-screen-region" ''
    if [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
      SCREENSHOT=$(mktemp)
      ${lib.getExe kdePackages.spectacle} --background --nonotify --region --output $SCREENSHOT && ${lib.getExe tesseract} -l eng+rus $SCREENSHOT stdout | ${wl-clipboard}/bin/wl-copy
      rm $SCREENSHOT
    else
      ${lib.getExe grim} -g "$(${lib.getExe slurp})" - | ${lib.getExe pkgs.tesseract} -l eng+rus - stdout | ${pkgs.wl-clipboard}/bin/wl-copy
    fi
  '')
]
