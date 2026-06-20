{ pkgs, lib, ... }@args:
let
  inInterface = if args ? inInterface then args.inInterface else "wg0";
in
{
  services.pihole-ftl = {
    enable = true;

    #! build pihole-ftl with HAVE_NFTSET, to emable nftset_lines below
    package =
      with pkgs;
      pihole-ftl.overrideAttrs (previousAttrs: {
        buildInputs = (previousAttrs.buildInputs or [ ]) ++ [ pkgs.nftables ];
        NIX_CFLAGS_COMPILE = (previousAttrs.NIX_CFLAGS_COMPILE or "") + " -DHAVE_NFTSET";
        NIX_LDFLAGS = (previousAttrs.NIX_LDFLAGS or "") + " -lnftables";
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

    # TODO: unbound???
    settings = {
      dns = {
        upstreams = [
          "1.1.1.1"
          "1.0.0.1"
        ];

        domainNeeded = true;

        interface = inInterface;
        listeningMode = "SINGLE";
      };

      misc.dnsmasq_lines = import ../../nftset.nix { inherit lib; };
    };
  };

  systemd.services.pihole-ftl.after = [
    "nftables.service"
    "wg-quick-${inInterface}.service"
  ];

  #? fix idempotency of setup service
  systemd.services.pihole-ftl-setup.serviceConfig.SuccessExitStatus = "1";

  networking.firewall.interfaces.${inInterface} = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [
      53
      80
    ];
  };
}
