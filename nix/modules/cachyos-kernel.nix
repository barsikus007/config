{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  #! add this to flake inputs
  #? nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];
  # boot.kernelPackages = lib.mkForce pkgs.cachyosKernels.linuxPackages-cachyos-latest;
  # boot.kernelPackages = lib.mkForce pkgs.cachyosKernels.linuxPackages-cachyos-bore;
  boot.kernelPackages = lib.mkForce pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
  nix.settings.substituters = lib.mkAfter [ "https://attic.xuyh0120.win/lantian" ];
  nix.settings.trusted-public-keys = lib.mkAfter [
    "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
  ];
}
