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

  outputs = { self, nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        (final: prev: {
          unstable = import inputs.nixpkgs-unstable {
            inherit prev;
            system = prev.system;
            config.allowUnfree = true;
          };
        })
      ];
      # харам, платные приложения
      config.allowUnfreePredicate =
        pkg:
        builtins.elem (nixpkgs.lib.getName pkg) [
          "nvidia-x11"
          "nvidia-settings"
          "nvidia-persistenced"

          "steam"
          "steam-unwrapped"
          "steam-original"
          "steam-run"

          "parsec-bin"

          "unrar"

          "microsoft-edge"
          "obsidian"
          "bcompare"
          "davinci-resolve-studio"
        ];
    };
    username = "ogurez";
    flakePath = "/home/${username}/config/nix";

    defaultSpecialArgs = {
      inherit inputs username flakePath;
    };
    specialArgs = defaultSpecialArgs // {
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
        inputs.nixos-wsl.nixosModules.default
        inputs.home-manager.nixosModules.home-manager
        ./hosts
        ./hosts/ROG14-WSL/configuration.nix
      ];
    };
    nixosConfigurations."ROG14" = nixpkgs.lib.nixosSystem {
      inherit system;
      inherit specialArgs;
      inherit pkgs;
      modules = [
        #? https://github.com/NixOS/nixos-hardware/blob/master/asus/zephyrus/ga401/default.nix
        inputs.nixos-hardware.nixosModules.asus-zephyrus-ga401
        inputs.home-manager.nixosModules.home-manager
        ./hosts
        ./hosts/ROG14/configuration.nix

        ./modules/stylix.nix
        ./modules/docker.nix

        ./modules/gui/vm.nix
        ./modules/gui/steam.nix
        ./modules/gui/wireguard.nix
        ./modules/gui/video-edit.nix
        ./modules/hardware/logi-mx3.nix

        ./packages/fixes/security.nix
        {
          # services.pipewire.extraConfig.pipewire."92-low-latency" = {
          #   "context.properties" = {
          #     #? https://github.com/wwmm/easyeffects/issues/1514
          #     "default.clock.force-quantum" = 1024;
          #     # "default.clock.rate" = 48000;
          #     # "default.clock.quantum" = 32;
          #     # "default.clock.min-quantum" = 32;
          #     # "default.clock.max-quantum" = 32;
          #   };
          # };

          environment.defaultPackages = with pkgs; [
            (libsForQt5.callPackage ./packages/bcompare.nix { })
          ];
        }
      ];
    };
    homeConfigurations."nixos" = inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        username = "nixos";
        flakePath = "/home/nixos/config/nix";
      };
      modules = [
        ./home
        ./home/shells.nix
        ./home/editors.nix
      ];
    };
    homeConfigurations.${username} = inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = specialArgs;
      modules = [
        ./home
        ./home/shells.nix
        ./home/editors.nix

        ./home/stylix.nix

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
