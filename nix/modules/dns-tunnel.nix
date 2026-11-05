{
  lib,
  pkgs,
  config,
  ...
}@args:
let
  domain = args.domain or "a.example.com";
  key = args.key or "0123456789abcdef0123456789abcdef";
  containerIp = args.containerIp or "10.88.0.53";

  dataDir = "/var/lib/masterdnsvpn";
  encryptKey = pkgs.writeText "encrypt_key.txt" key;
in
{
  networking.nftables = {
    enable = true;
    tables.dns-tunnel-redirect = {
      family = "inet";
      content = /* nft */ ''
        chain prerouting {
          type nat hook prerouting priority dstnat - 1; policy accept;
          iifname != "lo" meta l4proto { tcp, udp } th dport 53 ct mark set meta mark | 0x00001000 dnat ip to ${containerIp}:53
        }
      '';
    };
  };

  virtualisation.oci-containers.containers.masterdnsvpn = {
    image = "ghcr.io/masterking32/masterdnsvpn:latest";
    autoStart = true;
    environment = {
      DOMAIN = domain;
    };
    extraOptions = [
      "--ip=${containerIp}"
    ];
    volumes = [ "${dataDir}:/data:rw" ];
  };

  systemd.services."${config.virtualisation.oci-containers.backend}-masterdnsvpn" = {
    #! masterdnsvpn rewrites encrypt_key.txt during startup
    preStart = lib.mkBefore ''
      ${lib.getExe' pkgs.coreutils "install"} --mode=0600 ${encryptKey} ${dataDir}/encrypt_key.txt
    '';
    serviceConfig = {
      StateDirectory = "masterdnsvpn";
      StateDirectoryMode = "0700";
    };
  };
}
