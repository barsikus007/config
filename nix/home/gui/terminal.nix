{
  lib,
  pkgs,
  flakePath,
  ...
}:
#! 170Mb
let
  wezterm-run-script = pkgs.writeShellScript "wezterm-run-script" /* shell */ ''
    script=$1
    cd "$(dirname "$script")" || exit 1
    echo "$script"
    if [ -x "$script" ]; then
      "$script"
    else
      ${lib.getExe pkgs.bash} "$script"
    fi
    status=$?
    echo
    read -rsn1 -p "[exit $status] press any key to close..."
  '';
  terminalApps = [
    "wezterm-run-script.desktop"
    "org.wezfurlong.wezterm.desktop"
  ];
in
{
  #? dedicated runner: wezterm's own .desktop drops %f, so scripts never execute
  xdg.desktopEntries.wezterm-run-script = {
    name = "WezTerm Run Script in GUI";
    comment = "Run Script in GUI WezTerm Window";
    icon = "org.wezfurlong.wezterm";
    exec = "${lib.getExe pkgs.wezterm} start -- ${wezterm-run-script} %f";
    terminal = false;
    noDisplay = true;
    mimeType = [ "application/x-shellscript" ];
  };
  xdg.mimeApps.associations.added."application/x-shellscript" = terminalApps;
  xdg.mimeApps.defaultApplications."application/x-shellscript" = terminalApps;
  xdg.terminal-exec.settings.default = "org.wezfurlong.wezterm.desktop";
  programs.zsh.shellAliases = {
    wt = "wezterm start --cwd ./";
  };
  programs.wezterm = {
    enable = true;
    extraConfig = "return dofile('${flakePath}/.config/wezterm/wezterm.lua')";
  };
}
