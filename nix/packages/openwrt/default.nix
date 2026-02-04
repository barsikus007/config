{ }:
rec {
  amneziaPackages = {
    #? nix hash convert sha256:hash
    kmod-amneziawg = {
      hash."24.10.3_aarch64_cortex-a53_qualcommax_ipq807x" =
        "sha256-LDKsMEnc2XA6SWGqT7asJxt5+oi4mSFvYFJFhRoV3jA=";
      hash."24.10.4_aarch64_cortex-a53_qualcommax_ipq807x" =
        "sha256-s/47qvaWvs7ldfgHSLWEYQnGVntPemUGQCzh4OKApTg=";
      hash."24.10.3_mipsel_24kc_ramips_mt76x8" = "sha256-1OKtFVRRXAqcSl8PMIdKETOpB8H3ogKrPBGTqbA7yHs=";
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
      hash."24.10.4_aarch64_cortex-a53_qualcommax_ipq807x" =
        "sha256-gTSG0gXDpi4eAPaO3XZt/L2VxoDeamEcL5XKMwUfKIw=";
      hash."24.10.3_mipsel_24kc_ramips_mt76x8" = "sha256-AIFGr8bCmRlccVDyxmIiRC54BzIYucfP1FXaHTER6iA=";
      depends = [
        "libc"
        "kmod-amneziawg"
      ];
    };
    luci-proto-amneziawg = {
      # arch independent?
      hash."24.10.3_aarch64_cortex-a53_qualcommax_ipq807x" =
        "sha256-sETVdjrRawl7OEF/xAp3JAbJXX8eSK1s0CQPLtw1q9Q=";
      hash."24.10.4_aarch64_cortex-a53_qualcommax_ipq807x" =
        "sha256-ARBo/xYe9gtoIfrEwbaRGUor3IKrO8uFP/9DAd8cqOg=";
      hash."24.10.3_mipsel_24kc_ramips_mt76x8" = "sha256-sETVdjrRawl7OEF/xAp3JAbJXX8eSK1s0CQPLtw1q9Q=";
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
      profile,
      arch,
      #? https://openwrt.org/toh/hwdata/<vendor>/<vendor>_<device>
    }:
    let
      release_string = "${profile.release}_${arch}_${profile.target}_${profile.variant}";
    in
    builtins.mapAttrs (name: amneziaPkg: rec {
      inherit (amneziaPkg) depends;
      type = "real";
      filename = "${name}_v${release_string}.ipk";
      file = builtins.fetchurl {
        url = "https://github.com/Slava-Shchipunov/awg-openwrt/releases/download/v${profile.release}/${filename}";
        sha256 = amneziaPkg.hash.${release_string};
      };
    }) amneziaPackages;
}
