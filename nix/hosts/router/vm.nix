{
  lib,
  pkgs,
  base ? import ./base.nix { inherit lib pkgs; },
  ...
}:
{
  deploy = {
    host = "127.0.0.1";
    sshConfig = {
      Port = 62222;
      StrictHostKeyChecking = "no";
      UserKnownHostsFile = "/dev/null";
      ServerAliveInterval = 3;
      ServerAliveCountMax = 2;
    };
  };

  deploySteps.packages = {
    copy = lib.mkForce "";
    apply = lib.mkForce "";
  };

  uci.retain = [
    "luci"
    "rpcd"
    "ucitrack"
    "qemu_ga"
  ];

  inherit (base) etc;

  uci.settings = {
    network = {
      inherit (base.network) globals;
      interface = base.network.interface // {
        wan = {
          device = "eth1";
          proto = "dhcp";
          ipv6 = false;
          metric = 1;
        };
        wan6 = {
          device = "eth1";
          proto = "dhcpv6";
          reqaddress = "try";
          reqprefix = "auto";
          disabled = true;
          norelease = true;
        };
        awg0 = {
          proto = "amneziawg";
          private_key = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          dns = [ "10.42.69.1" ];
          addresses = [ "10.42.69.2/24" ];
        };
        wg0local = {
          proto = "amneziawg";
          private_key = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          listen_port = 51820;
          addresses = [ "192.168.228.1/24" ];
        };
      };
      amneziawg_awg0 = [
        {
          description = "test-peer";
          public_key = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          preshared_key = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          allowed_ips = [
            "0.0.0.0/0"
            "::/0"
          ];
          endpoint_host = "10.0.2.2";
          endpoint_port = 53;
        }
      ];
      device = [
        {
          name = "br-lan";
          type = "bridge";
          ports = [ "eth0" ];
          ipv6 = false;
        }
      ];
    };

    inherit (base) firewall;
    inherit (base) dhcp;
    inherit (base) pbr;

    system = {
      system = [
        {
          hostname = "OpenWrt-VM";
          description = "OpenWrt x86_64 VM";
          zonename = "Europe/Moscow";
          timezone = "MSK-3";
          conloglevel = 8;
          cronloglevel = 5;
        }
      ];
      inherit (base.system) timeserver;
    };

    dropbear.dropbear = base.dropbear;
    inherit (base) uhttpd;
  };
}
