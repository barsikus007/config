{ pkgs, ... }:
with pkgs;
[
  (writeShellScriptBin "inspect-window" ''
    WINDOW_ID=$(${kdotool}/bin/kdotool getactivewindow)
    if [ -z "$WINDOW_ID" ]; then
      ${lib.getExe libnotify} "Error" "No valid window ID obtained. Did you focus a window?" --urgency=critical
      exit 1
    fi

    PID=$(${kdotool}/bin/kdotool getwindowpid "$WINDOW_ID")
    if [ -z "$PID" ]; then
        ${lib.getExe libnotify} "Error" "No valid PID obtained for window ID $WINDOW_ID." --urgency=critical
        exit 1
    fi

    ${lib.getExe wezterm} start --always-new-process -- ${lib.getExe btop} --filter "$PID"
  '')
  (writeShellScriptBin "spectacle-ocr" ''
    SCREENSHOT=$(mktemp)
    ${lib.getExe kdePackages.spectacle} --background --nonotify --region --output $SCREENSHOT && ${lib.getExe tesseract} -l eng+rus $SCREENSHOT stdout | ${wl-clipboard}/bin/wl-copy
  '')
]
