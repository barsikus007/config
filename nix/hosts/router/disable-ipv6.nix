{ lib, ... }:
#? https://3os.org/infrastructure/openwrt/disable-ipv6
{
  uci.settings = {
    network.globals.globals.ula_prefix = lib.mkForce "";
    network.interface.lan.ip6assign = lib.mkForce "disabled";
    network.interface.wan.ipv6 = false;
    network.interface.wan6 = lib.mkForce { };

    dhcp.dhcp.lan = {
      dhcpv6 = lib.mkForce "disabled";
      ra = lib.mkForce "disabled";
      ndp = lib.mkForce "disabled";
    };
  };
}
