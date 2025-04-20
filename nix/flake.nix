{
  description = "https://никспобеда.рф";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    # nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-wsl,
      home-manager,
      nvf,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      username = "nixos";
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
          home-manager.nixosModules.home-manager
          ./hosts
          ./hosts/ROG14-WSL/configuration.nix
          {
            home-manager.useGlobalPkgs = true;
          }
        ];
      };
      nixosConfigurations."ROG14" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          home-manager.nixosModules.home-manager
          ./hosts
          ./hosts/ROG14/configuration.nix
        ];
      };
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit username; };
        modules = [
          nvf.homeManagerModules.default # <- this imports the home-manager module that provides the options
          ./home.nix
          ./modules/shells.nix
          ./modules/editors.nix

          ./modules/mpv.nix
        ];
      };
    };
}
