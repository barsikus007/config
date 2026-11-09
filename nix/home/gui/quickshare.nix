{ pkgs, ... }:
#! https://github.com/Martichou/rquickshare/issues/429
#! https://github.com/Martichou/rquickshare/issues/121
#? rquickshare seems died, move to packet (it have same issues)
#! https://github.com/nozwock/packet/issues/162
#! https://github.com/nozwock/packet/issues/117
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
