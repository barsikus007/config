{ pkgs, ... }:
{
  xdg.autostart = {
    enable = true;
    entries = [
      # "${pkgs.throne}/share/applications/throne.desktop"
      (
        (pkgs.makeDesktopItem rec {
          destination = "/";
          name = "Throne";
          desktopName = name;
          # exec = "${lib.getExe pkgs.throne} -tray -appdata";
          exec = "${name} -tray -appdata";
          terminal = false;
          categories = [ "Network" ];
          # type = "Application"; #? default
          startupNotify = false;
          extraConfig = {
            "X-GNOME-Autostart-enabled" = "true";
            "X-KDE-autostart-after" = "panel";
          };
        })
        + /Throne.desktop
      )
    ];
  };
  # ".config/autostart/vesktop.desktop".text = ''
  #   [Desktop Entry]
  #   Type=Application
  #   Name=Vesktop
  #   Comment=Vesktop autostart script
  #   Exec="${pkgs.electron.unwrapped}/libexec/electron/electron" "${pkgs.vesktop}/opt/Vesktop/resources/app.asar" "--enable-speech-dispatcher"
  #   StartupNotify=false
  #   Terminal=false

  #   X-KDE-autostart-after=panel
  # '';
}
