{
  pkgs,
  config,
  username,
  ...
}:
{
  networking.wg-quick.interfaces = {
    awg0 = {
      autostart = false;
      type = "amneziawg";
      configFile = "/home/${username}/awg0.conf";
    };
    wg0local = {
      autostart = false;
      # type = "amneziawg";
      configFile = "/home/${username}/wg0local.conf";
    };
  };

  environment.systemPackages = with pkgs; [
    wireguard-tools
    amneziawg-tools
  ];

  networking.networkmanager.dispatcherScripts =
    let
      wifiIface = "wlp2s0";
    in
    [
      #? https://networkmanager.dev/docs/api/latest/NetworkManager-dispatcher.html
      {
        source = pkgs.writeScript "local-wg-auto" ''
          #!/bin/sh
          [ "$DEVICE_IFACE" != "${wifiIface}" ] && exit 0
          [ "$2" != "up" ] && exit 0
          if [ "$CONNECTION_ID" = $(cat ${config.sops.secrets."hosts/NAS/router/ssid".path}) ]; then
            ${pkgs.systemd}/bin/systemctl stop wg-quick-wg0local
          else
            ${pkgs.systemd}/bin/systemctl start wg-quick-wg0local
          fi
        '';
        type = "basic";
      }
    ];
}
