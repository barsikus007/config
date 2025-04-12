{
  description = "System configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    # nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL?ref=main";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf.url = "github:notashelf/nvf";
  };

  outputs =
    { self, nixpkgs, nixos-wsl, home-manager, nvf, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations."ROG14-WSL" = nixpkgs.lib.nixosSystem {
        inherit system;
        # Edit this configuration file to define what should be installed on
        # your system. Help is available in the configuration.nix(5) man page, on
        # https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

        # NixOS-WSL specific options are documented on the NixOS-WSL repository:
        # https://github.com/nix-community/NixOS-WSL
        modules = [
          # include NixOS-WSL modules
          nixos-wsl.nixosModules.default
          {
            # This value determines the NixOS release from which the default
            # settings for stateful data, like file locations and database versions
            # on your system were taken. It's perfectly fine and recommended to leave
            # this value at the release version of the first install of this system.
            # Before changing this value read the documentation for this option
            # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
            system.stateVersion = "24.11"; # Did you read the comment?
            networking.hostName = "ROG14-WSL"; # Define your hostname

            wsl.enable = true;
            wsl.defaultUser = "nixos";
            wsl.docker-desktop.enable = true;
            wsl.startMenuLaunchers = true;
            wsl.usbip.enable = true;

            # https://nix-community.github.io/NixOS-WSL/how-to/vscode.html
            programs.nix-ld = {
              enable = true;
            };
          }
          ./configuration.nix
        ];
      };
      homeConfigurations."nixos" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          # nvf.homeManagerModules.nix
          nvf.homeManagerModules.default # <- this imports the home-manager module that provides the options
          ./home.nix
          ./soft/shells.nix
          ./soft/editors.nix
        ];
      };
    };
}
