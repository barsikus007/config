{
  description = "https://никспобеда.рф";

  nixConfig = {
    substituters = [
      "https://cache.nixos.org/"
      "https://nixos-cache-proxy.cofob.dev"

      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="

      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    #? nixpkgs-previous.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs-previous.url = "github:nixos/nixpkgs?ref=879bd460b3d3e8571354ce172128fbcbac1ed633";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware?ref=master";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    stylix = {
      url = "github:nix-community/stylix?ref=release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    openwrt-imagebuilder = {
      url = "github:astro/nix-openwrt-imagebuilder";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  #! FUCK THIS NIXFMT INDENT: https://github.com/NixOS/nixfmt/issues/91
  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import ./nixpkgs.nix { inherit system inputs; };
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
        inherit system pkgs;
        specialArgs = specialArgs // {
          username = "nixos";
          flakePath = "/home/nixos/config/nix";
        };
        modules = [
          ./hosts
          ./hosts/ROG14-WSL/configuration.nix
        ];
      };
      nixosConfigurations."ROG14" = nixpkgs.lib.nixosSystem {
        inherit system specialArgs pkgs;
        modules = [
          ./hosts
          ./hosts/ROG14/configuration.nix

          ./modules/hardware/logi-mx3.nix
          ./modules/hardware/xbox.nix
          ./modules/hardware/wifi-unlimited.nix

          ./modules/containers
          ./modules/network.nix
          ./modules/swap.nix
          ./modules/java.nix
          ./modules/stylix.nix
          ./modules/security.nix
          ./modules/wireguard.nix
          ./modules/zapret.nix
          ./modules/android.nix
          ./modules/diagnostic.nix
          ./modules/printer.nix

          ./modules/gui
          ./modules/gui/plasma.nix
          ./modules/gui/vm.nix
          ./modules/gui/games.nix
          ./modules/gui/nekoray.nix
          ./modules/gui/remote.nix
          ./modules/gui/waydroid.nix
          (import ./modules/gui/video-edit.nix { pkgs = pkgs.previous; })

          {
            programs.nix-ld.libraries = with pkgs; [
              #? nix-index
              #? nix-locate -- lib/libgobject-2.0.so.0
              #? https://unix.stackexchange.com/a/522823
              #? https://wiki.nixos.org/wiki/Nix-ld
              # stdenv.cc.cc
              # zlib
              # curl
              # openssl

              # fuse3
              # icu
              # nss
              # expat
              xorg.libX11
              # vulkan-headers
              # vulkan-loader
              # vulkan-tools

              glib
              freetype
            ];

            environment.defaultPackages = with pkgs; [
              (callPackage ./packages/anicli-ru { })
              (callPackage ./packages/libspeedhack { })
              (import ./packages/kompas3d/fhs.nix { pkgs = previous; })
            ];
          }
        ];
      };
      homeConfigurations."nixos" = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = specialArgs // {
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

          ./home/hardware/anime.nix

          ./home/stylix.nix
          ./home/shell/404.nix

          ./home/gui
          ./home/gui/sound.nix
          ./home/gui/autostart.nix
          ./home/gui/syncthing.nix
          ./home/gui/quickshare.nix
          ./home/gui/terminal.nix
          ./home/gui/plasma.nix
          ./home/gui/rofi.nix
          ./home/gui/mpv.nix
          ./home/gui/minecraft.nix
          ./home/gui/vscode.nix
          ./home/gui/browser.nix
          ./home/gui/social.nix
          ./home/gui/office.nix
          ./home/gui/bcompare.nix
          {
            programs.nvf.settings.vim.lsp.enable = nixpkgs.lib.mkForce true;
          }
        ];
      };
      devShells.${system} = {
        default = pkgs.mkShell {
          # nix develop ~/config/nix
          # packages = with pkgs; [
          #   unstable.
          # ];
          shellHook = ''
            echo "Welcome to the test ${pkgs.unstable.lib.version} devShell!"
            zsh; exit
          '';
        };
        python =
          let
            pythonPkg = pkgs.python313;
          in
          pkgs.mkShell {
            # nix develop ~/config/nix#python
            packages = with pkgs; [
              (pythonPkg.withPackages (
                python-pkgs: with python-pkgs; [
                  uv
                  ruff
                ]
              ))
              hatch
            ];
            shellHook = ''
              echo "Welcome to the Python ${pythonPkg.version} devShell!"
              zsh
            '';
          };
      };
      packages.${system} = with pkgs; {
        #? nix run --inputs-from nixpkgs github:barsikus007/config?dir=nix#<packageName>
        bcompare5 = (libsForQt5.callPackage ./packages/bcompare5.nix { });
        # nix build ./nix#bcompare5 && ./result/bin/bcompare
        mprint = callPackage ./packages/mprint.nix { };
        libspeedhack = callPackage ./packages/libspeedhack { };
        shikiwatch-appimage = callPackage ./packages/shikiwatch-appimage.nix { };
        shikiwatch-native = callPackage ./packages/shikiwatch-native.nix { };
        # nix build ./nix#shikiwatch-appimage && ./result/bin/ShikiWatch
        kompas3d = callPackage ./packages/kompas3d { };
        # nix build ./nix#kompas3d && ./result/bin/kompas-v24
        kompas3d-fhs = (import ./packages/kompas3d/fhs.nix { inherit pkgs; });
        # nix run ./nix#kompas3d-fhs
        grdcontrol = callPackage ./packages/grdcontrol.nix { };
        # nix build ./nix#grdcontrol && ./result/opt/guardant/grdcontrol/grdcontrold
        openwrt-xiaomi_ax3600 = (import ./packages/openwrt/xiaomi_ax3600.nix { inherit pkgs inputs; });
      };
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
