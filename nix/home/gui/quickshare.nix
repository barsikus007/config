{ pkgs, ... }:
let
  port = 12345;
in
{
  home.packages = with pkgs; [
    rquickshare
  ];

  custom.firewall.allowedTCPPorts = [ port ];

  xdg.dataFile."dev.mandre.rquickshare/.settings.json" = {
    text = builtins.toJSON {
      startminimized = true;
      visibility = 0;
      autostart = true;
      realclose = false;
      inherit port;
    };
    mutable = true;
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
