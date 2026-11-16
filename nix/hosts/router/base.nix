{ lib, ... }:
let
  inherit (import ../../shared/split-routing-domains.nix) groups;
  inherit (import ./stock-defaults.nix)
    stockNetwork
    stockFirewall
    stockDhcp
    stockUhttpd
    stockSystem
    ;

  byName = lib.listToAttrs (map (g: lib.nameValuePair g.name g) groups);

  pbrInterface = {
    exit = "awg0";
    direct = "wan";
  };

  #? cidrs go first to match how these lists were originally typed into luci
  mkDomainPolicy =
    name:
    let
      g = byName.${name};
    in
    {
      inherit name;
      dest_addr = lib.concatStringsSep " " ((g.cidrs or [ ]) ++ (g.domains or [ ]));
      interface = pbrInterface.${g.via};
    }
    // lib.optionalAttrs (!(g.enabled or true)) { enabled = false; };

  etc = {
    "init.d/free-turn-proxy".text = builtins.readFile ./files/init.d/free-turn-proxy;
    "hotplug.d/iface/26-white-ip-miner".text =
      builtins.readFile ./files/hotplug.d/iface/26-white-ip-miner;
    "hotplug.d/iface/70-pbr".text = builtins.readFile ./files/hotplug.d/iface/70-pbr;
    "rc.local".text = builtins.readFile ./files/rc.local;
  };

  network = {
    inherit (stockNetwork) interface;
    globals.globals.packet_steering = true;
  };

  firewall = stockFirewall;

  dhcp = {
    dnsmasq = [
      (
        stockDhcp.dnsmasq
        // {
          rebind_domain = [ "syncthing.net" ];
          #! pbr's dnsmasq.nftset resolver needs this mount to exist
          addnmount = [ "/var/run/pbr.dnsmasq" ];
        }
      )
    ];
    dhcp = stockDhcp.dhcp // {
      lan = stockDhcp.dhcp.lan // {
        #? docs.openwrt.melmac.ca/pbr/1.1.8/#Warning:Pleasesetdhcp.lan.force1
        force = true;
      };
    };
    inherit (stockDhcp) odhcpd;
    domain = [
      {
        name = "router";
        ip = "192.168.1.1";
      }
    ];
  };

  pbr = {
    pbr.config = {
      enabled = true;
      strict_enforcement = false;
      resolver_set = "dnsmasq.nftset";
      procd_reload_delay = 1;
      webui_show_ignore_target = true;
      supported_interface = [ "awg0" ];
    };
    #! pbr walks this list in order, so keep it in the order it had in luci
    policy = [
      {
        name = "wg-local";
        interface = "ignore";
        dest_addr = "192.168.228.0/24";
      }
    ]
    ++ map mkDomainPolicy [
      "torrents"
      "anime-nonru"
      "non-ru"
      "ai"
      "youtube"
      "telegram"
      "telegram-v6"
      "discord"
      "ru"
      "ru-vk"
      "ru-ya"
      "shit-sites"
    ]
    ++ [
      {
        name = "VPN by default";
        dest_addr = "0.0.0.0/0";
        interface = "awg0";
      }
    ];
  };

  system = stockSystem;

  dropbear = [
    {
      PasswordAuth = "off";
      Port = 2222;
      GatewayPorts = "on";
      RootPasswordAuth = "off";
    }
  ];

  uhttpd = stockUhttpd;
in
{
  inherit
    mkDomainPolicy
    etc
    network
    firewall
    dhcp
    pbr
    system
    dropbear
    uhttpd
    ;
}
