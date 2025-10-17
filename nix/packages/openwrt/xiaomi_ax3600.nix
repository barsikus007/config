{ pkgs, inputs, ... }:
#? https://openwrt.org/toh/xiaomi/ax3600
let
  profiles = inputs.openwrt-imagebuilder.lib.profiles { inherit pkgs; };
  initialConfig = profiles.identifyProfile "xiaomi_ax3600";

  amneziaPackages = {
    kmod-amneziawg = {
      hash."24.10.3_aarch64_cortex-a53_qualcommax_ipq807x" =
        "sha256-LDKsMEnc2XA6SWGqT7asJxt5+oi4mSFvYFJFhRoV3jA=";
      depends = [
        "kernel"
        "kmod-udptunnel4"
        "kmod-udptunnel6"
        "kmod-crypto-lib-chacha20poly1305"
        "kmod-crypto-lib-curve25519"
      ];
    };
    amneziawg-tools = {
      hash."24.10.3_aarch64_cortex-a53_qualcommax_ipq807x" =
        "sha256-hqGD4ejE3BI51VaI/dclPYBcKfA7/aD0kUHAnMATLX4=";
      depends = [
        "libc"
        "kmod-amneziawg"
      ];
    };
    luci-proto-amneziawg = {
      hash."24.10.3_aarch64_cortex-a53_qualcommax_ipq807x" =
        "sha256-sETVdjrRawl7OEF/xAp3JAbJXX8eSK1s0CQPLtw1q9Q=";
      depends = [
        "libc"
        "amneziawg-tools"
        "ucode"
        "luci-lib-uqr"
        "resolveip"
      ];
    };
  };

  mkAmneziaPackages =
    {
      release,
      arch,
    /*
      VERSION=$(grep '^DISTRIB_RELEASE=' /etc/openwrt_release | cut -d "'" -f 2)
      PKGARCH=$(grep '^DISTRIB_ARCH=' /etc/openwrt_release | cut -d "'" -f 2)
      TARGET=$(grep '^DISTRIB_TARGET=' /etc/openwrt_release | cut -d "'" -f 2)
      SUBTARGET=$(echo $TARGET | cut -d "/" -f 2)
      TARGET=$(echo $TARGET | cut -d "/" -f 1)
      arch="${VERSION}_${PKGARCH}_${TARGET}_${SUBTARGET}"
    */
    }:
    builtins.mapAttrs (name: amneziaPkg: rec {
      inherit (amneziaPkg) depends;
      type = "real";
      filename = "${name}_v${release}_${arch}.ipk";
      file = pkgs.fetchurl {
        url = "https://github.com/Slava-Shchipunov/awg-openwrt/releases/download/v${release}/${filename}";
        hash = amneziaPkg.hash."${release}_${arch}";
      };
    }) amneziaPackages;
in
inputs.openwrt-imagebuilder.lib.build (
  initialConfig
  // {
    # specify release
    # release = "24.10.3";

    # add package to include in the image, ie. packages that you don't
    # want to install manually later
    packages = [
      #? terminal related
      # "zsh"
      "bash"
      "tmux"
      "iperf3"

      #? VPN related
      "-dnsmasq"
      "dnsmasq-full"
      "luci-app-pbr"
      "luci-proto-wireguard" # ? I use amneziawg instead
      "kmod-amneziawg"
      "amneziawg-tools"
      "luci-proto-amneziawg"

      #? other
      "luci-app-sqm"
      "luci-app-wol"
      "luci-app-ddns"
    ];

    extraPackages = mkAmneziaPackages {
      release = initialConfig.release;
      arch = "aarch64_cortex-a53_qualcommax_ipq807x";
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
                    ./etc/uci-defaults/99-custom
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
