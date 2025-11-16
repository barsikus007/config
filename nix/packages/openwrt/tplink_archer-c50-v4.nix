{ pkgs, inputs, ... }:
#? https://openwrt.org/toh/tp-link/archer_a5_v5
#? https://openwrt.org/toh/tp-link/archer-c50
#? https://openwrt.org/toh/hwdata/tp-link/tp-link_archer_a5_v5
#? https://openwrt.org/toh/hwdata/tp-link/tp-link_archer_c50_v4
#  Package architecture: mipsel_24kc
let
  profiles = inputs.openwrt-imagebuilder.lib.profiles { inherit pkgs; };
  profile = (
    profiles.identifyProfile "tplink_archer-c50-v4"
    // {
      # specify release
      release = "24.10.3";
    }
  );
  arch = "mipsel_24kc";
  inherit (import ./. { }) mkAmneziaPackages;
in
inputs.openwrt-imagebuilder.lib.build (
  profile
  // {
    # add package to include in the image, ie. packages that you don't
    # want to install manually later
    packages = [
      #? terminal related
      "bash"
      # "fish"
      "tmux"
      "iperf3"

      #? VPN related
      "-dnsmasq"
      "dnsmasq-full"
      "luci-app-pbr"
      # "luci-proto-wireguard" # ? I use amneziawg instead
      "kmod-amneziawg"
      "amneziawg-tools"
      "luci-proto-amneziawg"

      #? other
      "luci-app-sqm"
      "luci-app-wol"
      "luci-app-ddns"
    ];

    extraPackages = mkAmneziaPackages {
      inherit profile arch;
    };

    # disabledServices = [ "dnsmasq" ];

    # include files in the images.
    # to set UCI configuration, create a uci-defaults scripts as per
    # official OpenWrt ImageBuilder recommendation.
    #? https://openwrt.org/docs/guide-developer/uci-defaults
    files =
      pkgs.runCommand "image-files"
        {
          src = pkgs.lib.fileset.toSource {
            root = ./.;
            fileset =
              pkgs.lib.fileset.difference
                (pkgs.lib.fileset.unions [
                  ./etc
                  ./root
                ])
                (
                  pkgs.lib.fileset.unions [
                    #? uncomment line below to disable custom settings (like enabling wireless)
                    # ./etc/uci-defaults/99-custom
                    ./root/.profile
                  ]
                );
          };
        }
        ''
          mkdir -p "$out/"
          cp -r --no-preserve=all "$src/"* "$out/"
        '';
  }
)
