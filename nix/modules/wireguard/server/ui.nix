{
  lib,
  pkgs,
  config,
  ...
}@args:
let
  inInterface = if args ? inInterface then args.inInterface else "wg0";
  inInterfaceCfg =
    if args ? inInterfaceCfg then
      args.inInterfaceCfg
    else
      { configFile = "/etc/wireguard/${inInterface}.conf"; };
  inInterfacePort = if args ? inInterfacePort then args.inInterfacePort else 51820;
  inInterfaceAddress = if args ? inInterfaceAddress then args.inInterfaceAddress else "10.69.228.1";
in
{
  imports = [ ../../../modules/services/networking/wireguard-ui.nix ];

  #? https://wiki.nixos.org/wiki/WireGuard#Disable_rpfilter
  networking.firewall.checkReversePath = "loose";

  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  networking.nat = {
    #? https://docs.kernel.org/networking/ip-sysctl.html
    #! this also set sysctl `net.ipv4.conf.all.forwarding` to 1 which sets `net.ipv4.ip_forward` to 1
    enable = true;
    internalInterfaces = [ inInterface ];
    #! `externalInterface` are unset due to possible multihop setup
  };
  networking.firewall.allowedUDPPorts = [ inInterfacePort ];
  networking.wg-quick.interfaces.${inInterface} = inInterfaceCfg;

  services.wireguard-ui = {
    enable = true;
    openFirewall = true;
    interface = inInterface;
    environment = {
      WGUI_MANAGE_START = "true";
      WGUI_MANAGE_RESTART = "true";

      WGUI_SERVER_INTERFACE_ADDRESSES = "${inInterfaceAddress}/24";
      WGUI_SERVER_LISTEN_PORT = toString inInterfacePort;
      #? for pihole-ftl dnsmasq routing
      WGUI_DNS = inInterfaceAddress;
    };
  };

  systemd.paths.wireguard-ui-watcher.enable =
    config.networking.wg-quick.interfaces.${inInterface} ? configFile;
  systemd.services.wireguard-ui-watcher.enable =
    config.networking.wg-quick.interfaces.${inInterface} ? configFile;
}
