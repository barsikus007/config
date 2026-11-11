{
  pkgs,
  arch,
  profile,
  ...
}:
#? https://github.com/astro/nix-openwrt-imagebuilder/blob/b44499745ce634773931f9912e5fa6d6be51db15/builder.nix
let
  commonDepends = {
    kmod-amneziawg = [
      "kernel"
      "kmod-udptunnel4"
      "kmod-udptunnel6"
      "kmod-crypto-lib-chacha20poly1305"
      "kmod-crypto-lib-curve25519"
    ];
    amneziawg-tools = [
      "libc"
      "kmod-amneziawg"
    ];
    luci-proto-amneziawg = [
      "libc"
      "amneziawg-tools"
      "ucode"
      "luci-lib-uqr"
      "resolveip"
    ];
  };

  #? https://github.com/Slava-Shchipunov/awg-openwrt/releases
  releases = {
    "25.12.6" = {
      versions = {
        kmod-amneziawg = "6.12.112.3.1.20260906-r1";
        amneziawg-tools = "3.1.20260812-r1";
        luci-proto-amneziawg = "3.1.0-r1";
      };
      targets = {
        aarch64_cortex-a53_qualcommax_ipq807x = {
          kmod-amneziawg = "sha256-nAMTrmo88r9fmzMPd13X1110t/Pn2bACE5mrN3UXpR4=";
          amneziawg-tools = "sha256-V1AoBqWj9D8UGZss+286pfozivCQcNo/Z0gyxaNlXag=";
          luci-proto-amneziawg = "sha256-xBJ2xnsAIVE2nOPMvicC11HGiI55g4vPaHjFD1PeklM=";
        };
        x86_64_x86_64 = {
          kmod-amneziawg = "sha256-ZBJGto6+dANgYCkW0NYwH/hcem+YBK6ykDI7AW2CyXc=";
          amneziawg-tools = "sha256-Lb5adC3zP98GBkyfPfXAG1BFfEfyAwvlcGaqk+uYjrM=";
          luci-proto-amneziawg = "sha256-/EReUhJ5c7LtNTWVIV/U5dlOP/Scw22SyIkuPYxBl+g=";
        };
      };
    };
  };
  mkAmneziaPackages =
    {
      arch,
      profile,
      #? https://openwrt.org/toh/hwdata/<vendor>/<vendor>_<device>
    }:
    let
      targetKey = "${arch}_${profile.target}_${profile.variant}";
      rel = releases.${profile.release};
      targetHashes = rel.targets.${targetKey};
    in
    builtins.mapAttrs (name: hash: {
      depends = commonDepends.${name};
      type = "real";
      filename = "${name}-${rel.versions.${name}}.apk";
      file = pkgs.fetchurl {
        url = "https://github.com/Slava-Shchipunov/awg-openwrt/releases/download/v${profile.release}/${name}_v${profile.release}_${targetKey}.apk";
        inherit hash;
      };
    }) targetHashes;

  authorizedKeys = pkgs.fetchurl {
    url = "https://github.com/barsikus007.keys";
    sha256 = "sha256-Tnf/WxeYOikI9i5l4e0ABDk33I5z04BJFApJpUplNi0=";
  };

  baseFiles = pkgs.lib.fileset.toSource {
    root = ./.;
    #! ./files is deliberately excluded: it holds what dewclaw pushes over ssh
    #! (hotplug scripts, rc.local), keeping one source of truth per file
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
          ]
        );
  };
in
{
  #? add package to include in the image, ie. packages that you don't want to install manually later
  packages = [
    "luci"

    #? terminal related
    "bash"
    "fish"
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

    #? doh dot
    "drill"

    #? other
    "luci-app-sqm"
    "luci-app-wol"
    "luci-app-ddns"
  ];
  extraPackages = mkAmneziaPackages {
    inherit profile arch;
  };

  # include files in the images;
  # to set UCI configuration, create a uci-defaults scripts as per official OpenWrt ImageBuilder recommendation
  #? https://openwrt.org/docs/guide-developer/uci-defaults
  files = pkgs.runCommand "image-files" { } ''
    mkdir -p "$out/etc/dropbear"
    cp -r --no-preserve=all "${baseFiles}/"* "$out/"
    cp "${authorizedKeys}" "$out/etc/dropbear/authorized_keys"
    chmod 0600 "$out/etc/dropbear/authorized_keys"
  '';
}
