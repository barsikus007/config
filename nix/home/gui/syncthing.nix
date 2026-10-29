{
  lib,
  pkgs,
  config,
  ...
}:
{
  services.syncthing = {
    enable = true;
    tray = {
      enable = true;
      command = "syncthingtray --wait --single-instance";
      package = pkgs.syncthingtray;
    };
  };

  custom.firewall = lib.mkIf config.services.syncthing.enable {
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [
      21027
      22000
    ];
  };
}
