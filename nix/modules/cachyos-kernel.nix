{ pkgs, inputs, ... }:
{
  #! add this to flake inputs
  #? nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];
  # boot.kernelPackages = pkgs.lib.mkForce pkgs.cachyosKernels.linuxPackages-cachyos-latest;
  # boot.kernelPackages = pkgs.lib.mkForce pkgs.cachyosKernels.linuxPackages-cachyos-bore;
  boot.kernelPackages = pkgs.lib.mkForce pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
}
