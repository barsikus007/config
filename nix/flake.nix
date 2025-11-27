{
  description = "https://никспобеда.рф";

  inputs = {
    nixpkgs-previous.url = "github:nixos/nixpkgs?ref=a871af02f1b36d22fadbc8ea5ad5f7fb22cc68e7";
    # nixpkgs-pinned.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # nixpkgs-master.url = "github:nixos/nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
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
    openwrt-imagebuilder = {
      url = "github:astro/nix-openwrt-imagebuilder";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-vfio = {
      url = "github:j-brn/nixos-vfio";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # TODO: FUCK THIS NIXFMT INDENT: https://github.com/NixOS/nixfmt/issues/91
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
      commonConfig.custom = {
        isAsus = true;
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
          ./shared

          ./hosts
          ./hosts/ROG14-WSL/configuration.nix
        ];
      };
      nixosConfigurations."ROG14" = nixpkgs.lib.nixosSystem {
        inherit system specialArgs pkgs;
        modules = [
          ./shared

          ./hosts
          ./hosts/ROG14/configuration.nix

          ./modules/hardware/logi-mx3.nix
          ./modules/hardware/xbox.nix
          ./modules/hardware/wifi-unlimited.nix

          ./modules/containers
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

          ./modules/gui
          ./modules/gui/plasma.nix
          ./modules/gui/sound.nix
          ./modules/gui/games.nix
          ./modules/gui/throne.nix
          ./modules/gui/remote.nix
          ./modules/gui/waydroid.nix

          ./modules/vm
          ./modules/vm/gui.nix
          ./modules/vm/vfio

          commonConfig
          {
            # TODO: unstable: https://github.com/NixOS/nixpkgs/issues/462935
            services.orca.enable = false;
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

            environment.defaultPackages = with pkgs; [
              (callPackage ./packages/anicli-ru { })
              (callPackage ./packages/shdotenv.nix { })
              (callPackage ./packages/libspeedhack { })
              (callPackage ./packages/kompas3d/fhs.nix { })
              #? needs 8.4 GiB * 3 (or more) space to build, takes ~12.2 GiB
              (callPackage ./packages/davinci-resolve-studio.nix { })
            ];
          }
        ];
      };
      nixosConfigurations."minimalIso-${system}" = nixpkgs.lib.nixosSystem {
        #? https://wiki.nixos.org/wiki/Creating_a_NixOS_live_CD
        inherit system;
        modules = [
          (
            { pkgs, modulesPath, ... }:
            {
              imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
              environment.systemPackages = import ./shared/lists { inherit pkgs; };

              systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
              users.users.root.openssh.authorizedKeys.keys = [
                (pkgs.lib.strings.removeSuffix "\n" (
                  builtins.readFile (
                    builtins.fetchurl {
                      url = "https://github.com/barsikus007.keys";
                      sha256 = "sha256-Tnf/WxeYOikI9i5l4e0ABDk33I5z04BJFApJpUplNi0=";
                    }
                  )
                ))
              ];

              #? https://wiki.nixos.org/wiki/Creating_a_NixOS_live_CD#Building_faster
              # isoImage.squashfsCompression = "gzip -Xcompression-level 1";
            }
          )
        ];
      };

      homeConfigurations."nixos" = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = specialArgs // {
          username = "nixos";
          flakePath = "/home/nixos/config/nix";
        };
        modules = [
          ./shared
          ./shared/nix.nix

          ./home
          ./home/shell/minimal.nix
          ./home/editors.nix
        ];
      };
      homeConfigurations.${username} = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = specialArgs;
        modules = [
          ./shared

          ./home
          ./home/shell
          ./home/editors.nix

          ./home/hardware/anime.nix

          ./home/stylix.nix
          ./home/shell/404.nix
          ./home/shell/bat.nix

          ./home/gui
          ./home/gui/sound.nix
          ./home/gui/autostart.nix
          ./home/gui/syncthing.nix
          ./home/gui/quickshare.nix
          ./home/gui/terminal.nix
          ./home/gui/plasma.nix
          ./home/gui/rofi.nix
          ./home/gui/mpv.nix
          ./home/gui/vscode.nix
          ./home/gui/browser.nix
          ./home/gui/social.nix
          ./home/gui/office.nix
          ./home/gui/bcompare.nix

          ./home/gui/games
          ./home/gui/games/minecraft.nix
          commonConfig
          {
            programs.nvf.settings.vim.lsp.enable = nixpkgs.lib.mkForce true;
          }
          {
            # TODO: home-manager-module: locales
            i18n.glibcLocales = (
              pkgs.callPackage ./packages/locale-cxx.nix {
                locales = [
                  "C.UTF-8/UTF-8"
                  "en_US.UTF-8/UTF-8"
                  "ru_RU.UTF-8/UTF-8"
                ];
              }
            );
          }
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
              echo "Welcome to the Python ${pythonPkg.version} devShell!"
              zsh; exit
            '';
          };
      };
      packages.${system} = with pkgs; {
        #? nix {build,run} ./nix# <tab>

        minimalIso = self.nixosConfigurations."minimalIso-${system}".config.system.build.isoImage;
        windowsBootstrapIso = callPackage ./packages/windows { };
        # nix build ./nix#windowsBootstrapIso -o unattend-win10-iot-ltsc-vrt.iso

        libfprint-27c6-521d = callPackage ./packages/libfprint-27c6-521d.nix { };
        goodix-patch-521d = callPackage ./packages/goodix-patch-521d.nix { };

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

        mprint = callPackage ./packages/mprint.nix { };
        libspeedhack = callPackage ./packages/libspeedhack { };

        flclashx = callPackage ./packages/flclashx.nix { };

        shikiwatch-appimage = callPackage ./packages/shikiwatch-appimage.nix { };
        shikiwatch-native = callPackage ./packages/shikiwatch-native.nix { };

        kompas3d = callPackage ./packages/kompas3d { };
        kompas3d-fhs = (import ./packages/kompas3d/fhs.nix { inherit pkgs; });
        grdcontrol = callPackage ./packages/grdcontrol.nix { };

        openwrt-xiaomi_ax3600 = (import ./packages/openwrt/xiaomi_ax3600.nix { inherit pkgs inputs; });
        openwrt-tplink_archer-c50-v4 = (
          import ./packages/openwrt/tplink_archer-c50-v4.nix { inherit pkgs inputs; }
        );
        # nix build ./nix#openwrt
        # or if hash mismatch
        # nix run <locally cloned nix-openwrt-imagebuilder>#generate-hashes <openwrt version>
        # nix build --override-input openwrt-imagebuilder <locally cloned nix-openwrt-imagebuilder> ./nix#openwrt
      };
      formatter.${system} = pkgs.nixfmt-tree;
    };
}
