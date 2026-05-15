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
  nix.settings.extra-substituters = [ "https://attic.xuyh0120.win/lantian" ];
  nix.settings.extra-trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];

  nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];
  # boot.kernelPackages = lib.mkForce pkgs.cachyosKernels.linuxPackages-cachyos-latest;
  # boot.kernelPackages = lib.mkForce pkgs.cachyosKernels.linuxPackages-cachyos-bore;
  boot.kernelPackages = lib.mkForce pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;

  boot.zfs.package = config.boot.kernelPackages.zfs_cachyos;
}
