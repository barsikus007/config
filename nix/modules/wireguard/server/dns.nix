{
  lib,
  pkgs,
  config,
  ...
}:
{
  custom.persist.directories = [
    {
      directory = "/var/lib/pihole";
      user = "pihole";
      group = "pihole";
      mode = "0700";
    }
  ];

  services.pihole-ftl = {
    enable = true;

    #! build pihole-ftl with HAVE_NFTSET, to emable nftset_lines below
    package = pkgs.pihole-ftl.overrideAttrs (previousAttrs: {
      buildInputs = (previousAttrs.buildInputs or [ ]) ++ [ pkgs.nftables ];
      env = (previousAttrs.env or { }) // {
        NIX_CFLAGS_COMPILE = (previousAttrs.env.NIX_CFLAGS_COMPILE or "") + " -DHAVE_NFTSET";
        NIX_LDFLAGS = (previousAttrs.env.NIX_LDFLAGS or "") + " -lnftables";
      };
    });

    queryLogDeleter.enable = true;

    lists = map (url: { inherit url; }) [
      #? base
      "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
      "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
      "https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt"
      "https://v.firebog.net/hosts/static/w3kbl.txt"
      "https://v.firebog.net/hosts/AdguardDNS.txt"
      "https://v.firebog.net/hosts/Admiral.txt"
      "https://v.firebog.net/hosts/Prigent-Ads.txt"
      "https://v.firebog.net/hosts/Easylist.txt"
      "https://v.firebog.net/hosts/Easyprivacy.txt"
      #? ru
      "https://schakal.ru/hosts/hosts.txt"
      #? mobile
      "https://raw.githubusercontent.com/jerryn70/GoodbyeAds/master/Hosts/GoodbyeAds.txt"
      "https://raw.githubusercontent.com/jerryn70/GoodbyeAds/master/Extension/GoodbyeAds-Xiaomi-Extension.txt"
      #? telemetry
      "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"
      "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/hosts/native.winoffice.txt"
      #? malware
      "https://raw.githubusercontent.com/blocklistproject/Lists/master/malware.txt"
    ];

    settings = {
      dns = {
        upstreams = [
          "1.1.1.1"
          "9.9.9.9"
          "8.8.8.8"
        ];

        domainNeeded = true;
        listeningMode = "NONE";
      };

      #? https://linux.die.net/man/8/dnsmasq
      misc.dnsmasq_lines = [
        "bind-interfaces"
      ]
      ++ map (iface: "interface=${iface}") (builtins.attrNames config.networking.wg-quick.interfaces)
      ++ [
        "interface=lo"
        "except-interface=podman*"
      ]
      ++ (import ../../nftset.nix { inherit lib; });
      #? sudo $(systemctl cat pihole-ftl | grep -o '/nix/store/[^ ]*-pihole-ftl-[^/]*/bin/pihole-FTL') --config webserver.api.password 'password'
      #! grep pwhash /etc/pihole/pihole.toml
      webserver.api.pwhash = lib.mkDefault "disabled";
    };
  };

  #? localhost bind is required: the setup service and `pihole` CLI hit the API
  #? over 127.0.0.1; wg0 bind ('o' = optional, in case wg0 is not up yet) serves
  #? clients. neither listens on WAN => panel reachable over wg0 only
  services.pihole-web = {
    enable = true;
    ports = [
      "127.0.0.1:8053"
      # "${inInterfaceAddress}:80o"
    ];
  };

  systemd.services.pihole-ftl.after = [
    "nftables.service"
  ];

  #? fix idempotency of setup service and skip on boot if database already exists
  systemd.services.pihole-ftl-setup = {
    unitConfig.ConditionPathExists = "!/var/lib/pihole/gravity.db";
    serviceConfig.SuccessExitStatus = "1";
  };

  networking.firewall.interfaces =
    lib.genAttrs (builtins.attrNames config.networking.wg-quick.interfaces)
      (_: {
        allowedUDPPorts = [ 53 ];
        allowedTCPPorts = [
          53
          80
        ];
      });
}
