#? stock OpenWrt defaults required for system operation
#? these are standard boilerplate options from upstream OpenWrt configs
#? (firewall rules, dnsmasq base options, odhcpd, loopback, uhttpd, ntp)
{
  stockNetwork = {
    interface = {
      loopback = {
        device = "lo";
        proto = "static";
        ipaddr = "127.0.0.1";
        netmask = "255.0.0.0";
      };
      lan = {
        device = "br-lan";
        proto = "static";
        ipaddr = "192.168.1.1";
        netmask = "255.255.255.0";
        ip6assign = 60;
      };
    };
  };

  stockFirewall = {
    defaults = [
      {
        input = "ACCEPT";
        output = "ACCEPT";
        forward = "REJECT";
        synflood_protect = true;
      }
    ];
    zone = [
      {
        name = "lan";
        input = "ACCEPT";
        output = "ACCEPT";
        forward = "ACCEPT";
        mtu_fix = true;
        network = [
          "lan"
          "wg0local"
        ];
      }
      {
        name = "wan";
        input = "REJECT";
        output = "ACCEPT";
        forward = "REJECT";
        masq = true;
        mtu_fix = true;
        network = [
          "wan"
          "wan6"
        ];
      }
      {
        name = "vpn";
        output = "ACCEPT";
        forward = "REJECT";
        input = "REJECT";
        masq = true;
        network = [ "awg0" ];
        mtu_fix = true;
      }
    ];
    rule = [
      {
        name = "Allow-DHCP-Renew";
        src = "wan";
        proto = "udp";
        dest_port = 68;
        target = "ACCEPT";
        family = "ipv4";
      }
      {
        name = "Allow-Ping";
        src = "wan";
        proto = "icmp";
        icmp_type = "echo-request";
        family = "ipv4";
        target = "ACCEPT";
      }
      {
        name = "Allow-IGMP";
        src = "wan";
        proto = "igmp";
        family = "ipv4";
        target = "ACCEPT";
      }
      {
        name = "Allow-DHCPv6";
        src = "wan";
        proto = "udp";
        dest_port = 546;
        family = "ipv6";
        target = "ACCEPT";
      }
      {
        name = "Allow-MLD";
        src = "wan";
        proto = "icmp";
        src_ip = "fe80::/10";
        icmp_type = [
          "130/0"
          "131/0"
          "132/0"
          "143/0"
        ];
        family = "ipv6";
        target = "ACCEPT";
      }
      {
        name = "Allow-ICMPv6-Input";
        src = "wan";
        proto = "icmp";
        icmp_type = [
          "echo-request"
          "echo-reply"
          "destination-unreachable"
          "packet-too-big"
          "time-exceeded"
          "bad-header"
          "unknown-header-type"
          "router-solicitation"
          "neighbour-solicitation"
          "router-advertisement"
          "neighbour-advertisement"
        ];
        limit = "1000/sec";
        family = "ipv6";
        target = "ACCEPT";
      }
      {
        name = "Allow-ICMPv6-Forward";
        src = "wan";
        dest = "*";
        proto = "icmp";
        icmp_type = [
          "echo-request"
          "echo-reply"
          "destination-unreachable"
          "packet-too-big"
          "time-exceeded"
          "bad-header"
          "unknown-header-type"
        ];
        limit = "1000/sec";
        family = "ipv6";
        target = "ACCEPT";
      }
      {
        name = "Allow-IPSec-ESP";
        src = "wan";
        dest = "lan";
        proto = "esp";
        target = "ACCEPT";
      }
      {
        name = "Allow-ISAKMP";
        src = "wan";
        dest = "lan";
        dest_port = 500;
        proto = "udp";
        target = "ACCEPT";
      }
    ];
    forwarding = [
      {
        src = "lan";
        dest = "wan";
      }
      {
        src = "lan";
        dest = "vpn";
      }
    ];
    include.pbr = {
      fw4_compatible = 1;
      type = "script";
      path = "/usr/share/pbr/firewall.include";
    };
  };

  stockDhcp = {
    dnsmasq = {
      domainneeded = true;
      localise_queries = true;
      rebind_protection = true;
      rebind_localhost = true;
      local = "/lan/";
      domain = "lan";
      expandhosts = true;
      authoritative = true;
      readethers = true;
      localservice = true;
      ednspacket_max = 1232;
      cachesize = 1000;
      strictorder = true;
    };
    dhcp = {
      lan = {
        interface = "lan";
        start = 100;
        limit = 150;
        leasetime = "12h";
        dhcpv4 = "server";
        dhcpv6 = "server";
        ra = "server";
        ra_flags = [
          "managed-config"
          "other-config"
        ];
      };
      wan = {
        interface = "wan";
        ignore = true;
      };
    };
    odhcpd.odhcpd = {
      maindhcp = false;
      leasefile = "/tmp/odhcpd.leases";
      leasetrigger = "/usr/sbin/odhcpd-update";
      loglevel = 4;
      piodir = "/tmp/odhcpd-piodir";
      hostsdir = "/tmp/hosts";
    };
  };

  stockUhttpd = {
    uhttpd.main = {
      listen_http = [
        "0.0.0.0:80"
        "[::]:80"
      ];
      listen_https = [
        "0.0.0.0:443"
        "[::]:443"
      ];
      home = "/www";
      rfc1918_filter = true;
      cert = "/etc/uhttpd.crt";
      key = "/etc/uhttpd.key";
      lua_prefix = [ "/cgi-bin/luci=/usr/lib/lua/luci/sgi/uhttpd.lua" ];
      tcp_keepalive = 1;
      ubus_prefix = "/ubus";
      ucode_prefix = [ "/cgi-bin/luci=/usr/share/ucode/luci/uhttpd.uc" ];
    };
    cert.defaults = {
      days = 730;
      key_type = "ec";
    };
  };

  stockSystem = {
    timeserver.ntp = {
      server = [
        "0.openwrt.pool.ntp.org"
        "1.openwrt.pool.ntp.org"
        "2.openwrt.pool.ntp.org"
        "3.openwrt.pool.ntp.org"
      ];
    };
  };
}
