{
  pkgs,
  username,
  inputs,
  ...
}:
{
  networking.hostName = "ROG14-WSL"; # Define your hostname

  environment.systemPackages = (import ../../shared/lists { inherit pkgs; })
  # ++ (import ../../shared/lists/extra.nix { inherit pkgs; })
  # ++ (import ../../shared/lists/test.nix { inherit pkgs; })
  #
  ;

  # Edit this configuration file to define what should be installed on
  # your system. Help is available in the configuration.nix(5) man page, on
  # https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

  # NixOS-WSL specific options are documented on the NixOS-WSL repository:
  # https://github.com/nix-community/NixOS-WSL
  imports = [
    # include NixOS-WSL modules
    inputs.nixos-wsl.nixosModules.default
  ];

  wsl.enable = true;
  wsl.defaultUser = username;
  wsl.docker-desktop.enable = true;
  wsl.interop.register = true;
  wsl.startMenuLaunchers = true;
  wsl.usbip.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
