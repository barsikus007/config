{
  lib,
  pkgs,
  modulesPath,
  ...
}:
#? https://github.com/nix-community/nixos-anywhere-examples/blob/7f945ff0ae676c0eb77360b892add91328dd1f17/configuration.nix
{
  imports = [
    ../minimal.nix
    ../../modules/ssh-secure.nix

    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];

  #! redefine this for security
  security.sudo.wheelNeedsPassword = lib.mkDefault false;

  boot.loader.grub = {
    #! no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  environment.systemPackages = import ../../shared/lists/00_essential.nix { inherit pkgs; };
}
