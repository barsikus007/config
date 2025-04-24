{
  description = "https://никспобеда.рф";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware?ref=master";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    stylix = {
      url = "github:danth/stylix?ref=release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixos-wsl,
    nixos-hardware,
    home-manager,
    plasma-manager,
    stylix,
    nvf,
    ...
  }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    # pkgsUnstable = nixpkgs-unstable.legacyPackages.${system};
    pkgsUnstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    username = "ogurez";
    flakePath = "/home/${username}/config/nix";
    defaultSpecialArgs = {
      inherit username flakePath;
    };
    specialArgs = defaultSpecialArgs // {
      unstable = pkgsUnstable;
    };
  in
  {
    nixosConfigurations."ROG14-WSL" = nixpkgs.lib.nixosSystem {
      inherit system;
      inherit specialArgs;
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
      inherit specialArgs;
      modules = [
        nixos-hardware.nixosModules.asus-zephyrus-ga401
        home-manager.nixosModules.home-manager
        stylix.nixosModules.stylix
        ./hosts
        ./hosts/ROG14/configuration.nix
        ./modules/gui/vm.nix
        {
          # Override networking.wg-quick to use unstable's module
          disabledModules = [ "services/networking/wg-quick.nix" ];
          imports = [
            "${nixpkgs-unstable}/nixos/modules/services/networking/wg-quick.nix"
          ];
          # Overlay to include amneziawg-tools
          nixpkgs.overlays = [
            (self: super: {
              amneziawg-tools = nixpkgs-unstable.legacyPackages.${system}.amneziawg-tools;
            })
          ];

          # hardware.graphics.package = nixpkgs-unstable.legacyPackages.${system}.mesa;

          # Include amneziawg package from unstable
          environment.systemPackages =
            with nixpkgs-unstable.legacyPackages.x86_64-linux;
            [
              wireguard-tools # Contains amneziawg support
              amneziawg-tools
            ]
            ++ (import packages/test.nix {
              inherit pkgs;
            });

          # Define a user account. Don't forget to set a password with ‘passwd’.
          users.users.${username} = {
            isNormalUser = true;
            extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
          };
          home-manager.useGlobalPkgs = true;
          # home-manager.useUserPackages = true;
        }
      ];
    };
    homeConfigurations."nixos" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        username = "nixos";
        flakePath = "/home/nixos/config/nix";
      };
      modules = [
        nvf.homeManagerModules.default # <- this imports the home-manager module that provides the options
        ./home
        ./home/shells.nix
        ./home/editors.nix
      ];
    };
    homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = defaultSpecialArgs;
      modules = [
        nvf.homeManagerModules.default # <- this imports the home-manager module that provides the options
        plasma-manager.homeManagerModules.plasma-manager
        ./home
        ./home/shells.nix
        ./home/editors.nix

        ./home/gui/terminal.nix
        ./home/gui/plasma.nix
        ./home/gui/mpv.nix
        {
          programs.nvf.settings.vim.languages.enableLSP = nixpkgs.lib.mkForce true;
        }
      ];
    };
  };
}
