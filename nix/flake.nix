{
  description = "https://никспобеда.рф";

  inputs = {
    # nixpkgs-previous.url = "nixpkgs/commit_hash";
    # nixpkgs-fix-for-<smth>.url = "nixpkgs/pull/1488/head";
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz"; # Smaller then github tarball, less api hits
    # nixpkgs-master.url = "nixpkgs";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

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
      url = "github:FlameFlag/nixcord";
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

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.noctalia-qs.follows = "noctalia-qs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
            (
              { lib, ... }:
              {
                home = {
                  inherit username;
                  homeDirectory = "/home/${username}";

                  #? https://nix-community.github.io/home-manager/release-notes.xhtml
                  stateVersion = lib.mkDefault "26.05";
                };
              }
            )
          ];
        };
      };
    in
    {
      nixosConfigurations."NixOS-WSL" = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        specialArgs = mkSpecialArgs "nixos";
        modules = [
          ./shared

          ./hosts/NixOS-WSL/configuration.nix
        ];
      };
      nixosConfigurations."ROG14" = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        specialArgs = mkSpecialArgs "ogurez" // {
          inherit custom;
        };
        modules = [
          ./shared

          ./hosts/ROG14/configuration.nix

          ./modules/hardware/logi-mx3.nix
          ./modules/hardware/xbox.nix

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
          #? mertech website is currently down
          # ./modules/printer.nix

          # ./modules/desktop/manager/plasma.nix
          ./modules/desktop/manager/niri-de.nix
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

              # fuse3
              # icu
              # nss
              # expat
              libx11
              # vulkan-headers
              # vulkan-loader
              # vulkan-tools

              glib
              freetype
              #? https://github.com/NixOS/nixpkgs/blob/cf468dffe856afaf83e755de82d20e72ccf183c2/pkgs/by-name/st/steam/package.nix#L72
            ]; # ++ pkgs.steam-run.args.multiPkgs pkgs;

            environment.systemPackages = with pkgs; [
              self.packages.${stdenv.hostPlatform.system}.games.hytale
              (callPackage ./packages/shdotenv.nix { })
              self.packages.${stdenv.hostPlatform.system}.libs.libspeedhack
              # self.packages.${stdenv.hostPlatform.system}.kompas3d-fhs
              #? needs 8.4 GiB * 3 (or more) space to build, takes ~12.2 GiB, and ~18 minutes to download
              (callPackage ./packages/auto/gui/davinci-resolve-studio.nix { })
            ];
          }
        ];
      };

      #? subset of my desktop system for testing purposes
      nixosConfigurations."coolvm" = nixpkgs.lib.nixosSystem {
        #? nh os build-vm --hostname coolvm && ./result/bin/run-*-vm
        # TODO: mouse capture and cursor; resolution; vfio; clipboard
        inherit system pkgs;
        specialArgs = mkSpecialArgs "ogurez";
        #? check every module impact on closure size:
        # nix path-info --closure-size --human-readable ./result
        modules = [
          # ./hosts/vm/paravirt-spiced.nix
          ./hosts/vm/niri-qemu.nix
          # ./hosts/vm/vfio-pass.nix
          {
            system.stateVersion = "26.05";
            networking.hostName = "coolvm";

            virtualisation.vmVariant.virtualisation = {
              diskImage = null;
              memorySize = 8 * 1024;
              cores = 8;
              #! sharedDirectories
              qemu.options = [
                "-monitor stdio"
                "-full-screen"
              ];
            };
          }
          # ./shared

          ./modules/desktop/manager/niri-de.nix
          # ./modules/desktop/manager/plasma.nix
          #! test area
          #? link current nixpkgs source to store
          (
            { username, ... }:
            {
              #! 152Mb
              environment.systemPackages = import ./shared/lists/02_add.nix { inherit pkgs; };
              #! +720Mb for nix tools, wtf
              # environment.systemPackages = import ./shared/lists { inherit pkgs; };

              #! 11Mb initial size
              home-manager.users.${username} = {
                imports = [
                  # ./shared

                  ./home
                  ./home/shell

                  ./home/gui/neovide.nix
                  ./home/gui/browser.nix
                  {
                    # inherit custom;
                    home.stateVersion = "26.05";
                  }
                ];
              };
            }
          )
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
                ./hosts/iso/.
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
                ./hosts/iso/plasma.nix
              ];
            }
          )
        ];
      };

      homeConfigurations =
        { }
        // mkHomeCfg "nixos" [
          ./shared
          ./shared/nix.nix
          ./shared/nh.nix

          ./home
          ./home/shell/minimal.nix
          ./home/editors.nix
        ]
        // mkHomeCfg "nixd" [
          #! https://github.com/nix-community/nixd/issues/705#issuecomment-3103731843
          inputs.nixcord.homeModules.default
          inputs.nvf.homeManagerModules.default
          inputs.plasma-manager.homeModules.plasma-manager
          inputs.niri.homeModules.niri
          inputs.noctalia.homeModules.default
          inputs.dms.homeModules.dank-material-shell
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
        rust = pkgs.mkShell {
          RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
          buildInputs = with pkgs; [
            cargo
            rustc
            rustfmt
            clippy
            rust-analyzer
          ];
          packages = with pkgs; [
            evcxr
          ];

          shellHook = ''
            echo "🦀 Welcome to the Rust ${with pkgs; rustc.version} devShell!"
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

          bcompare = (callPackage ./packages/bcompare.nix { }).overrideAttrs {
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
            # TODO: retest that it was fucked with unstable wine
            # wine = wineWow64Packages.unstableFull;
            wine = wineWow64Packages.stable;
            scale = 192;
            src = ./src.zip;
          };

          openwrt = {
            xiaomi_ax3600 = import ./packages/openwrt/xiaomi_ax3600.nix { inherit pkgs inputs; };
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
      formatter.${system} = with pkgs; nixfmt-tree;
    };
}
