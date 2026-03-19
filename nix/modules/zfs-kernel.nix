{
  lib,
  pkgs,
  config,
  ...
}:
#? https://wiki.nixos.org/wiki/ZFS#Selecting_the_latest_ZFS-compatible_Kernel
let
  zfsCompatibleKernelPackages = lib.filterAttrs (
    name: kernelPackages:
    (builtins.match "linux_[0-9]+_[0-9]+" name) != null
    && (builtins.tryEval kernelPackages).success
    && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
  ) pkgs.linuxKernel.packages;
  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
in
{
  #? Note this might jump back and forth as kernels are added or removed.
  boot.kernelPackages = latestKernelPackage;

  #? ZFS requires networking.hostId to be set
  networking.hostId = lib.mkDefault "c0febabe";
}
