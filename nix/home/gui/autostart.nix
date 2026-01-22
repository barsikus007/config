{ pkgs, config, ... }:
let
  replaceDesktopItem =
    package: name: newExec:
    (pkgs.runCommand name { } ''
      mkdir -p $out
      src=${package}/share/applications/${name}
      sed 's|^Exec=.*$|Exec=${newExec}|' "$src" > $out/${name}
    '')
    + /${name};
in
{
  xdg.autostart = {
    enable = true;
    entries = [
      (replaceDesktopItem pkgs.throne "throne.desktop"
        "${pkgs.throne}/share/throne/Throne -tray -appdata"
      )
      # extraConfig = {
      #   "X-KDE-autostart-after" = "panel";
      # };
      # outName = "Throne.desktop";

      (replaceDesktopItem pkgs.ayugram-desktop "com.ayugram.desktop.desktop" "AyuGram -autostart")
      (replaceDesktopItem config.programs.nixcord.finalPackage.vesktop "vesktop.desktop"
        "vesktop --start-minimized"
      )
      (replaceDesktopItem pkgs.syncthingtray "syncthingtray.desktop"
        "syncthingtray qt-widgets-gui --single-instance --wait"
      )
      # extraConfig = {
      #   "X-GNOME-Autostart-Delay" = 0;
      #   "X-GNOME-Autostart-enabled" = true;
      #   "X-LXQt-Need-Tray" = true;
      # };
    ];
  };
}
