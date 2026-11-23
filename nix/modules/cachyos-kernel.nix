{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
{
  #! add this to flake inputs
  #? nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  nix.settings.extra-substituters = [ "https://cache.lantian.pub/lantian?priority=43" ];
  nix.settings.extra-trusted-public-keys = [ "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ=" ];

  nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];
  boot.kernelPackages =
    let
      kp = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto;
      # kp = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;
      inTreeTools = lib.filterAttrs (
        name: val:
        name != "kernel"
        && (builtins.tryEval (lib.isDerivation val && (val.src or null) == kp.kernel.src)).value or false
      ) kp;
    in
    #? use cached upstream tools for in-tree utilities sharing kernel.src
    kp.extend (
      _kfinal: _kprev: lib.getAttrs (builtins.attrNames inTreeTools) pkgs.linuxPackages_latest
    );

  boot.zfs.package = config.boot.kernelPackages.zfs_cachyos;
  hardware.nvidia.branch = "latest";
}
