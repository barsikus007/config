{ lib, username, ... }:
{
  services.dae = {
    enable = true;
    configFile = "/home/${username}/Sync/config.dae";
    openFirewall.enable = false;
  };
  systemd.services.dae.wantedBy = lib.mkForce [ ];
}
