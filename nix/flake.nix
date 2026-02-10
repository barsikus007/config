{
  description = "https://никспобеда.рф";

  inputs = {
    # nixpkgs-previous.url = "nixpkgs/commit_hash";
    # nixpkgs-fix-for-<smth>.url = "nixpkgs/pull/1488/head";
    nixpkgs.url = "nixpkgs/nixos-unstable";
    # nixpkgs-master.url = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-vfio = {
      url = "github:j-brn/nixos-vfio";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    impermanence.url = "github:nix-community/impermanence";
    plasma-manager = {
      # TODO: unstable: https://github.com/nix-community/plasma-manager/issues/556
      url = "github:nix-community/plasma-manager?ref=d4fae3492172c388777380d67c67c53cc316ffcd";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    stylix = {
      url = "github:nix-community/stylix";
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
    erosanix = {
      url = "github:emmanuelrosa/erosanix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    openwrt-imagebuilder = {
      url = "github:astro/nix-openwrt-imagebuilder";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dewclaw = {
      url = "github:MakiseKurisu/dewclaw";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  # TODO: FUCK THIS NIXFMT INDENT: https://github.com/NixOS/nixfmt/issues/91
  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import ./nixpkgs.nix { inherit system inputs; };
      custom.isAsus = true;

      mkSpecialArgs = username: {
        inherit
          self
          inputs
          username
          ;
        flakePath = "/home/${username}/config/nix";
      };

      mkHomeCfg = username: modules: {
        ${username} = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = mkSpecialArgs username;
          modules = modules ++ [
            {
              home = {
                inherit username;
                homeDirectory = "/home/${username}";

                #? https://nix-community.github.io/home-manager/release-notes.xhtml
                stateVersion = "26.05";
              };
            }
          ];
        };
      };
    in
    {
      nixosConfigurations."ROG14-WSL" = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        specialArgs = mkSpecialArgs "nixos";
        modules = [
          ./shared

          ./hosts
          ./hosts/ROG14-WSL/configuration.nix
        ];
      };
      nixosConfigurations."ROG14" = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        specialArgs = mkSpecialArgs "ogurez" // {
          inherit custom;
        };
        modules = [
          ./shared

          ./hosts
          ./hosts/ROG14/configuration.nix
          ./hosts/ROG14/impermanence.nix

          ./modules/hardware/logi-mx3.nix
          ./modules/hardware/xbox.nix
          ./modules/hardware/wifi-unlimited.nix

          ./modules/shell
          ./modules/containers
          ./modules/silent-boot.nix
          ./modules/locale.nix
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

          ./modules/desktop/manager/plasma.nix
          ./modules/gui/sound.nix
          ./modules/gui/games.nix
          ./modules/gui/throne.nix
          ./modules/gui/remote.nix
          ./modules/gui/waydroid.nix

          ./modules/vm
          ./modules/vm/gui.nix
          ./modules/vm/vfio
          {
            inherit custom;
            programs.nix-ld.libraries = with pkgs; [
              #? nix-index
              #? nix-locate lib/libgobject-2.0.so.0
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
              #? https://github.com/NixOS/nixpkgs/blob/cf468dffe856afaf83e755de82d20e72ccf183c2/pkgs/by-name/st/steam/package.nix#L72
            ]; # ++ pkgs.steam-run.args.multiPkgs pkgs;

            environment.systemPackages = with pkgs; [
              self.packages.${system}.games.hytale
              (callPackage ./packages/shdotenv.nix { })
              self.packages.${system}.libs.libspeedhack
              # self.packages.${system}.kompas3d-fhs
              #? needs 8.4 GiB * 3 (or more) space to build, takes ~12.2 GiB, and ~18 minutes to download
              self.packages.${system}.gui.davinci-resolve-studio
            ];
          }
        ];
      };

      #? https://github.com/NixOS/nixpkgs/tree/master/nixos/modules/installer/cd-dvd
      nixosConfigurations."minimalIso-${system}" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = mkSpecialArgs "nixos";
        modules = [
          (
            { modulesPath, ... }:
            {
              imports = [
                (modulesPath + "/installer/cd-dvd/installation-cd-minimal-combined.nix")
                ./packages/iso.nix
              ];
            }
          )
        ];
      };
      nixosConfigurations."plasmaIso-${system}" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = mkSpecialArgs "nixos";
        modules = [
          (
            { modulesPath, ... }:
            {
              imports = [
                (modulesPath + "/installer/cd-dvd/installation-cd-base.nix")
                ./packages/iso.nix
              ];
              isoImage.edition = "graphical";
              isoImage.showConfiguration = nixpkgs.lib.mkDefault false;

              specialisation = {
                #? without gnome
                #? https://github.com/NixOS/nixpkgs/blob/fb9c69c7033731e7d3f713d9cc209065b8ad7f02/nixos/modules/installer/cd-dvd/installation-cd-graphical-combined.nix#L33
                plasma.configuration = {
                  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix") ];
                  isoImage.showConfiguration = true;
                  isoImage.configurationName = "Plasma (Linux LTS)";
                };
                plasma_latest_kernel.configuration =
                  { config, ... }:
                  {
                    imports = [
                      (modulesPath + "/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix")
                      (modulesPath + "/installer/cd-dvd/latest-kernel.nix")
                    ];
                    isoImage.showConfiguration = true;
                    isoImage.configurationName = "Plasma (Linux ${config.boot.kernelPackages.kernel.version})";
                  };
              };
            }
          )
        ];
      };

      homeConfigurations =
        { }
        // mkHomeCfg "nixos" [
          ./shared
          ./shared/nix.nix

          ./home
          ./home/shell/minimal.nix
          ./home/editors.nix
        ]
        // mkHomeCfg "nixd" [
          #! https://github.com/nix-community/nixd/issues/705#issuecomment-3103731843
          inputs.nixcord.homeModules.default
          inputs.nvf.homeManagerModules.default
          inputs.plasma-manager.homeModules.plasma-manager
        ];

      nixOnDroidConfigurations.default = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = import ./nixpkgs.nix {
          inherit inputs;
          system = "aarch64-linux";
          overlays = [
            inputs.nix-on-droid.overlays.default
          ];
        };
        extraSpecialArgs = mkSpecialArgs "nix-on-droid" // {
          flakePath = "/data/data/com.termux.nix/files/home/config/nix";
        };
        modules = [
          (
            { specialArgs, ... }:
            {
              home-manager.extraSpecialArgs = specialArgs;
            }
          )
          #! ./shared/nix.nix
          ./nix-on-droid.nix
        ];
      };

      devShells.${system} = {
        default = pkgs.mkShell {
          #? nix develop ~/config/nix
          packages = with pkgs; [
          ];
          shellHook = ''
            echo "Welcome to the test ${pkgs.lib.version} devShell!"
            zsh; exit
          '';
        };
        python =
          let
            pythonPkg = pkgs.python313;
          in
          pkgs.mkShell {
            #? nix develop ~/config/nix#python
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
              echo "🐍 Welcome to the Python ${pythonPkg.version} devShell!"
              zsh; exit
            '';
          };
      };
      packages.${system} =
        with pkgs;
        {
          #? nix {build,run} ./nix# <tab>

          nixosMinimalIso = self.nixosConfigurations."minimalIso-${system}".config.system.build.isoImage;
          nixosPlasmaIso = self.nixosConfigurations."plasmaIso-${system}".config.system.build.isoImage;
          windowsBootstrapIso = callPackage ./packages/windows { };
          # nix build ./nix#windowsBootstrapIso -o unattend-win10-iot-ltsc-vrt.iso

          bcompare5 = (libsForQt5.callPackage ./packages/bcompare5.nix { }).overrideAttrs {
            #? sorry, I can't buy this software right now (and trial doesn't work)
            #? https://gist.github.com/rise-worlds/5a5917780663aada8028f96b15057a67?permalink_comment_id=5168755#gistcomment-5168755
            postFixup = ''
              sed -i "s/AlPAc7Np1/AlPAc7Npn/g" $out/lib/beyondcompare/BCompare
            '';
          };

          telegram-desktop-patched = callPackage ./packages/telegram-desktop-patched.nix { };
          ayugram-desktop-patched = callPackage ./packages/telegram-desktop-patched.nix {
            telegram-desktop-client = ayugram-desktop;
          };

          kompas3d = kdePackages.callPackage ./packages/kompas3d { };
          kompas3d-fhs = callPackage ./packages/kompas3d/fhs.nix { };
          grdcontrol = callPackage ./packages/grdcontrol.nix { };

          #? https://github.com/emmanuelrosa/erosanix/tree/master/pkgs/mkwindowsapp
          # link src.zip to flake dir
          # `nvidia-offload nix run ./nix#photoshop`
          photoshop = callPackage ./packages/photoshop.nix {
            inherit (inputs.erosanix.lib."${system}") mkWindowsAppNoCC copyDesktopIcons makeDesktopIcon;
            #? its fucked with unstable wine
            # wine = wineWow64Packages.unstableFull;
            wine = wineWow64Packages.stable;
            scale = 192;
            src = ./src.zip;
          };

          openwrt = {
            xiaomi_ax3600 = (import ./packages/openwrt/xiaomi_ax3600.nix { inherit pkgs inputs; });
            tplink_archer-c50-v4 = (
              import ./packages/openwrt/tplink_archer-c50-v4.nix { inherit pkgs inputs; }
            );
            dewclaw-env = callPackage inputs.dewclaw {
              configuration = import ./packages/openwrt/dewclaw.nix;
            };
          };

          # nix build ./nix#openwrt
          # or if hash mismatch
          # nix run <locally cloned nix-openwrt-imagebuilder>#generate-hashes <openwrt version>
          # nix build --override-input openwrt-imagebuilder <locally cloned nix-openwrt-imagebuilder> ./nix#openwrt
        }
        // lib.filesystem.packagesFromDirectoryRecursive {
          inherit callPackage;
          directory = ./packages/auto;
        };
      formatter.${system} = pkgs.nixfmt-tree;
    };
}
