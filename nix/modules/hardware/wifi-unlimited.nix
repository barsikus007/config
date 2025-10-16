{
  lib,
  pkgs,
  config,
  ...
}:
# thx https://github.com/truelecter/infra/blob/08f01f1ef85e95de43b65fcb4f1cf9cb8883d2ba/nixos/hosts/x86_64/sirius/wifi.nix#L47
{
  # unlimited powah UwU
  #? https://github.com/NixOS/nixpkgs/issues/25378
  hardware.wirelessRegulatoryDatabase = true;
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="PA"
    options iwlwifi lar_disable=1
  '';
  boot.extraModulePackages =
    let
      iwlifi = pkgs.callPackage ../../packages/kmod/iwlwifi.nix {
        inherit (config.boot.kernelPackages) kernel;
      };
      iwlifi-larless = iwlifi.overrideAttrs (_: {
        patches = [ ../../packages/kmod/iwlwifi-lar_disable.patch ];
      });
    in
    [
      (lib.hiPrio iwlifi-larless)
    ];
  # boot.kernelPatches = [
  #   {
  #     name = "restore lar_disable module parameter";
  #     patch = (
  #       pkgs.fetchpatch2 {
  #         # https://github.com/torvalds/linux/commit/f06021a18fcf8d8a1e79c5e0a8ec4eb2b038e153
  #         # https://gist.github.com/rhjdvsgsgks/7f6cce3d3b176a03e5b60427301bc9f9
  #         # https://github.com/truelecter/infra/blob/08f01f1ef85e95de43b65fcb4f1cf9cb8883d2ba/nixos/hosts/x86_64/sirius/kmod/iwlwifi-lar_disable.patch
  #         url = "https://raw.githubusercontent.com/truelecter/infra/08f01f1ef85e95de43b65fcb4f1cf9cb8883d2ba/nixos/hosts/x86_64/sirius/kmod/iwlwifi-lar_disable.patch";
  #         hash = "sha256-GGc8yje3IsxVBYCAzQc3g3gss6zSBYRxANqsLSkXYLU=";
  #       }
  #     );
  #   }
  # ];
}
