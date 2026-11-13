{
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
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto;
  # boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;

  boot.zfs.package = config.boot.kernelPackages.zfs_cachyos;
  hardware.nvidia.branch = "latest";
}
