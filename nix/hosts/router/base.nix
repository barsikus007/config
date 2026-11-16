{ lib, ... }:
let
  inherit (import ../../shared/split-routing-domains.nix) groups;

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
in
{
  imports = [
    ./stock-defaults.nix
  ];

  _module.args = {
    inherit mkDomainPolicy;
  };

  etc = {
    "init.d/free-turn-proxy".text = builtins.readFile ./files/init.d/free-turn-proxy;
    "hotplug.d/iface/26-white-ip-miner".text =
      builtins.readFile ./files/hotplug.d/iface/26-white-ip-miner;
    "hotplug.d/iface/70-pbr".text = builtins.readFile ./files/hotplug.d/iface/70-pbr;
    "rc.local".text = builtins.readFile ./files/rc.local;
  };

  uci.settings = {
    network = {
      globals.globals.packet_steering = true;
    };

    dhcp = {
      #? docs.openwrt.melmac.ca/pbr/1.1.8/#Warning:Pleasesetdhcp.lan.force1
      dhcp.lan.force = true;
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
    };

    dropbear.dropbear = [
      {
        PasswordAuth = "off";
        Port = 2222;
        GatewayPorts = "on";
        RootPasswordAuth = "off";
      }
    ];
  };
}
