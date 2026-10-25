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

    (modulesPath + "/profiles/qemu-guest.nix")

    #? debloat
    (modulesPath + "/profiles/minimal.nix")
    { services.logrotate.enable = true; }
    (modulesPath + "/profiles/perlless.nix")
    {
      options.system.forbiddenDependenciesRegexes = lib.mkOption {
        apply = builtins.filter (x: x != "perl");
      };
      #! userborn creates users too late for impermanence on fresh installs
      config.services.userborn.enable = false;
    }
  ];

  #! redefine this for security
  security.sudo.wheelNeedsPassword = lib.mkDefault false;

  boot.loader.grub = {
    #! most hosters use legacy BIOS, so no systemd-boot :(
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  #? explicit DNS for all servers: 1.1.1.1 fastest, 9.9.9.9 independent fallback, 8.8.8.8 last resort
  networking.nameservers = [
    "1.1.1.1"
    "9.9.9.9"
    "8.8.8.8"
  ];

  environment.systemPackages = import ../../shared/lists/00_essential.nix { inherit pkgs; };
}
