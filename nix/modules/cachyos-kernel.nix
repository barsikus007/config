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
  nix.settings.extra-substituters = [ "https://attic.xuyh0120.win/lantian" ];
  nix.settings.extra-trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
}
