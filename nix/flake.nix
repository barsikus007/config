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
      nixpkgs-unstable = nixpkgs-unstable;
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
        # https://github.com/NixOS/nixos-hardware/blob/master/asus/zephyrus/ga401/default.nix
        nixos-hardware.nixosModules.asus-zephyrus-ga401
        home-manager.nixosModules.home-manager
        stylix.nixosModules.stylix
        ./hosts
        ./hosts/ROG14/configuration.nix

        ./modules/gui/vm.nix
        ./modules/gui/steam.nix
        ./modules/gui/wireguard.nix
        ./modules/gui/video-edit.nix
        ./modules/hardware/logi-mx3.nix

        ./packages/fixes/security.nix
        {
          # hardware.graphics.package = nixpkgs-unstable.legacyPackages.${system}.mesa;

          # харам, fhs
          services.envfs.enable = true;

          # харам, платные приложения
          nixpkgs.config.allowUnfreePredicate =
            pkg:
            builtins.elem (nixpkgs.lib.getName pkg) [
              "nvidia-x11"
              "nvidia-settings"
              "nvidia-persistenced"

              "steam"
              "steam-unwrapped"
              "steam-original"
              "steam-run"

              "microsoft-edge"
              "obsidian"
              "bcompare"
              "davinci-resolve-studio"
            ];

          environment.defaultPackages = (
            import packages/test.nix {
              inherit pkgs;
              unstable = pkgsUnstable;
            } ++ [
              (pkgs.libsForQt5.callPackage ./packages/bcompare.nix {})
            ]
          );
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
      extraSpecialArgs = specialArgs;
      modules = [
        nvf.homeManagerModules.default # <- this imports the home-manager module that provides the options
        plasma-manager.homeManagerModules.plasma-manager
        ./home
        ./home/shells.nix
        ./home/editors.nix

        ./home/gui/autostart.nix
        ./home/gui/sound.nix
        ./home/gui/syncthing.nix
        ./home/gui/terminal.nix
        ./home/gui/plasma.nix
        ./home/gui/mpv.nix
        ./home/gui/minecraft.nix
        ./home/gui/vscode.nix
        {
          programs.nvf.settings.vim.languages.enableLSP = nixpkgs.lib.mkForce true;
        }
      ];
    };
  };
}
