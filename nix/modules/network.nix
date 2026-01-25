{
  lib,
  config,
  username,
  ...
}:
let
  hmConfig = config.home-manager.users.${username};
in
{
  networking.networkmanager.enable = true;
  #? dns
  services.resolved.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  # networking.nameservers = [
  #   "8.8.8.8"
  #   "4.4.4.4"
  # ];
  networking.hosts = {
    "130.255.77.28" = [ "ntc.party" ];
    "95.182.120.241" = [
      "sora.com"
      "sora.chatgpt.com"
    ];
  };

  # networking.firewall.enable = false;
  # TODO: unified custom config: firewall: rquickshare,syncthing
  networking.firewall = {
    allowedTCPPorts =
      [ ]
      ++ lib.optionals (lib.any (pkg: lib.getName pkg == "rquickshare") hmConfig.home.packages) [ 12345 ]
      ++ lib.optionals hmConfig.services.syncthing.enable [ 22000 ];
    allowedUDPPorts =
      [ ]
      ++ lib.optionals hmConfig.services.syncthing.enable [
        21027
        22000
      ];
  };
}
