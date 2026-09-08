{
  lib,
  pkgs,
  config,
  username,
  ...
}:
let
  #? tunnel that must be down at home and up on any other network
  localTunnel = "wg0local";

  systemctl = lib.getExe' config.systemd.package "systemctl";
in
{
  networking.wg-quick.interfaces = {
    awg0 = {
      type = "amneziawg";
      autostart = false;
      configFile = "/home/${username}/Sync/awg0.conf";
    };
    ${localTunnel} = {
      autostart = false;
      configFile = "/home/${username}/Sync/${localTunnel}.conf";
    };
  };

  environment.systemPackages = with pkgs; [
    wireguard-tools
    amneziawg-tools
  ];

  networking.networkmanager.dispatcherScripts = [
    #? https://networkmanager.dev/docs/api/latest/NetworkManager-dispatcher.html
    {
      source = pkgs.writeScript "local-wg-auto" ''
        #!/bin/sh
        [ -d "/sys/class/net/$DEVICE_IFACE/wireless" ] || exit 0
        [ "$2" != "up" ] && exit 0
        if [ "$CONNECTION_ID" = "$(cat ${config.sops.secrets."hosts/NAS/router/ssid".path})" ]; then
          ${systemctl} stop wg-quick-${localTunnel}
        else
          ${systemctl} start wg-quick-${localTunnel}
        fi
      '';
      type = "basic";
    }
  ];

  #! a tunnel kept across S3 still owns the ~. routing domain while its peer
  #! session is already dead, so every DNS query after resume goes into the void
  #! and starves the nsncd worker pool, see ../network.nix
  #? the local tunnel returns through the dispatcher above, awg0 is started by hand
  powerManagement.powerDownCommands = lib.concatMapStringsSep "\n" (
    name: "${systemctl} stop wg-quick-${name} || true"
  ) (lib.attrNames config.networking.wg-quick.interfaces);
}
