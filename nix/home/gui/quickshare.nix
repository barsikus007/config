{ pkgs, ... }:
{
  home.packages = with pkgs; [
    rquickshare-legacy
  ];

  xdg.dataFile."dev.mandre.rquickshare/.settings.json".text = builtins.toJSON {
    startminimized = true;
    visibility = 0;
    autostart = true;
    realclose = false;
    port = 12345; # TODO: system: firewall
  };

  xdg.configFile."autostart/RQuickShare.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Version=1.0
    Name=RQuickShare
    Comment=RQuickSharestartup script
    Exec=rquickshare
    StartupNotify=false
    Terminal=false
  '';
}
