{ lib, pkgs, ... }@args:
let
  inInterface = args.inInterface or "awg0";
  inInterfacePort = args.inInterfacePort or 51820;
  inInterfaceAddress = args.inInterfaceAddress or "10.69.228.1";
in
{
  imports = [
    (import ./. args)
    ../../../modules/services/networking/wireguard-ui.nix
  ];

  services.wireguard-ui = {
    enable = true;
    openFirewall = true;
    interface = inInterface;
    environment = {
      # WGUI_PASSWORD_HASH_FILE = "secret";
      WGUI_MANAGE_START = "true";
      WGUI_MANAGE_RESTART = "true";

      # WGUI_ENDPOINT_ADDRESS = "domain.example.net";
      WGUI_SERVER_INTERFACE_ADDRESSES = "${inInterfaceAddress}/24";
      WGUI_SERVER_LISTEN_PORT = toString inInterfacePort;
      #? for pihole-ftl dnsmasq routing
      WGUI_DNS = inInterfaceAddress;
    };
  };
}
