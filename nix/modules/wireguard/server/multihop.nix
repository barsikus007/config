{ pkgs, ... }@args:
let
  inInterface = if args ? inInterface then args.inInterface else "wg0";
  ruListUrl =
    if args ? ruListUrl then
      args.ruListUrl
    else
      "https://stat.ripe.net/data/country-resource-list/data.json?v4_format=prefix&resource=ru";
in
{
  networking.nftables = {
    enable = true;
    tables.split-routing = {
      family = "inet";
      content = /* nft */ ''
        set rfc1918 {
          type ipv4_addr
          flags interval
          elements = { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 }
        }

        #? RIPE routes
        set ru_ips {
          type ipv4_addr
          flags interval
        }

        #? DNS routes
        set force_exit {
          type ipv4_addr
          flags timeout
          timeout 1h
        }
        set force_direct {
          type ipv4_addr
          flags timeout
          timeout 1h
        }

        chain prerouting {
          type filter hook prerouting priority mangle; policy accept;

          #? only process forwarded traffic from VPN clients (for SSH)
          iifname != "${inInterface}" return
          ip daddr @rfc1918 return

          #? DNS routes have more priority
          ip daddr @force_direct return
          ip daddr @force_exit meta mark set 120 return

          ip daddr @ru_ips return

          #? other traffic is marked for multihop
          meta mark set 120
        }
      '';
    };
  };

  #? sudo nft list set inet split-routing ru_ips | wc -l
  systemd.services.update-ru-routes = {
    description = "Update RU IP routes for nftables";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [
      "network-online.target"
      "nftables.service"
    ];
    path = with pkgs; [
      curl
      jq
      gawk
      nftables
      coreutils
      cidr-merger
    ];
    script = /* shell */ ''
      set -o errexit
      set -o nounset
      set -o pipefail

      NFT_FILE="/tmp/ru_ips.nft"

      {
        echo "flush set inet split-routing ru_ips"
        echo "add element inet split-routing ru_ips {"

        curl --silent --show-error --location "${ruListUrl}" \
          | jq --raw-output ".data.resources.ipv4[]" \
          | cidr-merger --batch \
          | awk '{printf "%s, ", $0}'

        echo "}"
      } > "$NFT_FILE"

      nft --file "$NFT_FILE"
    '';
    serviceConfig = {
      Type = "oneshot";
      PrivateTmp = true;

      #? sometimes it eats all RAM, for no reason, lol
      MemoryMax = "128M";
      MemorySwapMax = "0";
    };
  };

  systemd.timers.update-ru-routes = {
    description = "Run RU route updater daily";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };
}
