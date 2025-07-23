{ lib, pkgs, ... }:
{
  xdg.configFile = {
    # TODO    osConfig.programs.nekoray.package
    # TODO if osConfig.programs.nekoray.enabled
    "autostart/nekoray.desktop".text = ''
      [Desktop Entry]
      Name=nekoray
      Exec=${lib.getExe pkgs.nekoray} -tray -appdata
      Terminal=false
      Categories=Network
      Type=Application
      StartupNotify=false
      X-GNOME-Autostart-enabled=true

      X-KDE-autostart-after=panel
    '';
    "autostart/RQuickShare.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Version=1.0
      Name=RQuickShare
      Comment=RQuickSharestartup script
      Exec=${pkgs.rquickshare-legacy}/bin/.r-quick-share-wrapped
      StartupNotify=false
      Terminal=false
    '';
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
  };
}
