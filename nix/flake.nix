{
  description = "https://никспобеда.рф";

  inputs = {
    # nixpkgs-previous.url = "nixpkgs/commit_hash";
    # nixpkgs-fix-for-<smth>.url = "nixpkgs/pull/1488/head";
    #? smaller then github tarball, less api hits: https://discourse.nixos.org/t/use-channels-as-flake-inputs/75261
    #? more secure: https://determinate.systems/blog/nixpkgs-cooldown/
    nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1";
    # nixpkgs-master.url = "nixpkgs";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    #! https://github.com/nix-community/nix-on-droid/issues/495
    nixpkgs-unstable-droid.url = "nixpkgs/88d3861";
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs-unstable-droid";
      inputs.home-manager.follows = "home-manager";
    };
    impermanence.url = "github:nix-community/impermanence";
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
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    niri.url = "github:sodiboo/niri-flake";
    noctalia.url = "github:noctalia-dev/noctalia/cachix";
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
      custom = {
        isAsus = true;
        # blur.enable = true;
      };

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
            ./home
          ];
        };
      };

      mkCoolVm =
        name: username: modules:
        nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          specialArgs = mkSpecialArgs username;
          modules = modules ++ [
            #? link current nixpkgs source to store to avoid refetching it withing guest
            ./shared/options.nix
            ./hosts/vm
            (
              { username, ... }:
              {
                networking.hostName = "coolvm";

                virtualisation.vmVariant.virtualisation = {
                  diskImage = null;
                  memorySize = 8 * 1024;
                  cores = 8;
                  #! sharedDirectories
                  qemu.options = [
                    # "-full-screen"
                  ];
                };

                #! 152Mb
                environment.systemPackages = import ./shared/lists/02_add.nix { inherit pkgs; };
                #! +720Mb for nix tools, wtf
                # environment.systemPackages = import ./shared/lists { inherit pkgs; };

                #! 11Mb initial size
                home-manager.users.${username} = {
                  imports = [
                    ./shared/options.nix

                    ./home
                    ./home/shell

                    ./home/gui/neovide.nix
                    ./home/gui/browser/firefox.nix
                    {
                      inherit custom;
                    }
                  ];
                };

                users.users.${username}.initialPassword = "0";
              }
            )
          ];
        };
    in
    {
      nixosConfigurations."NixOS-WSL" = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        specialArgs = mkSpecialArgs "nixos";
        modules = [
          ./shared/options.nix

          ./hosts/NixOS-WSL/configuration.nix
        ];
      };
      nixosConfigurations."ROG14" = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        specialArgs = mkSpecialArgs "ogurez" // {
          inherit custom;
        };
        modules = [
          ./shared/options.nix

          ./hosts/ROG14/configuration.nix

          ./modules/hardware/logi-mx3.nix
          ./modules/hardware/xbox.nix
          ./modules/hardware/gamepad-kbd.nix
          ./modules/hardware/esp32.nix

          ./modules/nix-ld.nix
          ./modules/containers
          ./modules/silent-boot.nix
          ./modules/network.nix
          ./modules/swap.nix
          ./modules/java.nix
          ./modules/stylix.nix
          ./modules/security.nix
          ./modules/wireguard/client.nix
          ./modules/proxy-client.nix
          ./modules/android.nix
          ./modules/diagnostic.nix
          ./modules/printer.nix

          # ./modules/desktop/manager/plasma.nix
          ./modules/desktop/manager/niri-de.nix
          # ./modules/desktop/manager/niri-dms.nix
          ./modules/gui/sound.nix
          ./modules/gui/games.nix
          ./modules/gui/throne.nix
          ./modules/gui/remote.nix
          ./modules/gui/waydroid.nix

          ./modules/vm
          ./modules/vm/gui.nix
          ./modules/vm/vfio

          ./modules/services/networking/wireguard-ui.nix
          # TODO: ./modules/system/activation
          {
            # TODO: unstable: https://github.com/amnezia-vpn/amneziawg-linux-kernel-module/pull/176#issuecomment-4757244261
            nixpkgs.overlays = [
              (_: prev: {
                cachyosKernels = prev.cachyosKernels // {
                  linuxPackages-cachyos-bore-lto = prev.cachyosKernels.linuxPackages-cachyos-bore-lto.extend (
                    _: lpsuper: {
                      amneziawg = lpsuper.amneziawg.overrideAttrs (old: {
                        patches = (old.patches or [ ]) ++ [
                          (prev.fetchpatch2 {
                            name = "tmp-fix-for-new-kernel-without-ipv6-stub.patch";
                            url = "https://github.com/amnezia-vpn/amneziawg-linux-kernel-module/commit/2a764691e22f15770aa1551ecae12c0431dbd651.patch?full_index=1";
                            stripLen = 1;
                            hash = "sha256-0BcCDBu5XHk1kTrx/24Nwq15n01tCRqnQfBkEvzJmxs=";
                          })
                        ];
                      });
                    }
                  );
                };
              })
            ];
          }
          {
            inherit custom;

            programs.nh.clean.enable = nixpkgs.lib.mkForce false;

            environment.systemPackages = with pkgs; [
              self.packages.${stdenv.hostPlatform.system}.hytale
              (callPackage ./packages/shdotenv.nix { })
              self.packages.${stdenv.hostPlatform.system}.libspeedhack
              # self.packages.${stdenv.hostPlatform.system}.kompas3d-fhs
              #? needs 8.4 GiB * 3 (or more) space to build, takes ~12.2 GiB, and ~18 minutes to download
              (callPackage ./packages/auto/gui/davinci-resolve-studio.nix { })
            ];
          }
        ];
      };

      #? nixos-anywhere --flake ./nix#generic-VPS --generate-hardware-config nixos-generate-config ./nix/hardware-configuration.nix --target-host <hostname>
      nixosConfigurations."NAS" = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        specialArgs = mkSpecialArgs "admin" // {
          inherit custom;
        };
        modules = [
          ./hosts/NAS/configuration.nix

          ./modules/copy-flake.nix
          ./modules/samba.nix
          (
            {
              lib,
              pkgs,
              username,
              ...
            }:
            {
              imports = [
                (import ./modules/services/ytarchive.nix {
                  inherit lib pkgs username;
                  channels = [
                  ];
                })
                (import ./modules/services/streamlink.nix {
                  inherit lib pkgs username;
                  channels = [
                  ];
                })
              ];
            }
          )
          (
            { username, ... }:
            import ./modules/containers/docker.nix {
              inherit username;
              storageDriver = "zfs";
            }
          )
          {
            environment.systemPackages = with pkgs; [
              bun
              litecli
            ];
          }
        ];
      };

      #? nixos-anywhere --flake ./nix#NAS-vmtest --vm-test
      nixosConfigurations."NAS-vmtest" = self.nixosConfigurations."NAS".extendModules {
        modules = [
          ./hosts/NAS/vmtest.nix
        ];
      };

      #? nixos-anywhere --flake ./nix#generic-VPS --generate-hardware-config nixos-generate-config ./nix/hosts/empty-hardware-configuration.nix --target-host <hostname>
      nixosConfigurations."generic-VPS" = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        specialArgs = mkSpecialArgs "nixos";
        modules = [
          ./hosts/vps
          ./hosts/vps/disk-config.nix
          ./hosts/empty-hardware-configuration.nix
        ];
      };

      #? subsets of my desktop systems for testing purposes
      nixosConfigurations."coolvm-niri" = mkCoolVm "niri" "ogurez" [
        ./hosts/vm/niri-paravirt.nix

        ./modules/desktop/manager/niri-de.nix
        # ./modules/desktop/manager/niri-dms.nix
      ];
      nixosConfigurations."coolvm-plasma" = mkCoolVm "plasma" "ogurez" [
        ./hosts/vm/kde-sunshined.nix
        #! ./result/bin/run-*-vm -device virtio-vga
        # ./hosts/vm/kde-sunshined-vfio.nix

        ./modules/desktop/manager/plasma.nix
      ];

      #? nix run ./nix#checks.x86_64-linux.circus.driver --offline
      checks.${system}.circus = import ./tests/circus.nix { inherit pkgs; };

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
                ./hosts/iso
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
            { username, modulesPath, ... }:
            {
              imports = [
                (modulesPath + "/installer/cd-dvd/installation-cd-base.nix")
                ./hosts/iso/plasma.nix
              ];
              home-manager.users.${username}.imports = [
                ./home/gui/terminal.nix
                ./home/gui/browser/firefox.nix
              ];
            }
          )
        ];
      };

      homeConfigurations = nixpkgs.lib.attrsets.mergeAttrsList [
        (mkHomeCfg "nixos" [
          ./shared/options.nix
          ./shared/nix.nix
          ./shared/nh.nix

          ./home
          ./home/shell/minimal.nix
          ./home/editors.nix
        ])
        (mkHomeCfg "nixd" [
          #! https://github.com/nix-community/nixd/issues/705#issuecomment-3103731843
          inputs.nixcord.homeModules.default
          inputs.nvf.homeManagerModules.default
          inputs.plasma-manager.homeModules.plasma-manager
          inputs.niri.homeModules.niri
          inputs.noctalia.homeModules.default
          inputs.dms.homeModules.dank-material-shell
        ])
      ];

      nixOnDroidConfigurations.default = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = import ./nixpkgs.nix {
          inherit inputs;
          system = "aarch64-linux";
          nixpkgs = inputs.nixpkgs-unstable-droid;
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
        let
          flattenPkgs = lib.concatMapAttrs (
            name: v:
            if lib.isDerivation v then
              { ${name} = v; }
            else if lib.isAttrs v then
              flattenPkgs v
            else
              { }
          );
        in
        {
          #? nix {build,run} ./nix# <tab>

          default = self.packages.${system}.coolvm-niri;
          coolvm-niri = self.nixosConfigurations."coolvm-niri".config.system.build.vm;
          coolvm-plasma = self.nixosConfigurations."coolvm-plasma".config.system.build.vm;
          nixos-minimalIso = self.nixosConfigurations."minimalIso-${system}".config.system.build.isoImage;
          nixos-plasmaIso = self.nixosConfigurations."plasmaIso-${system}".config.system.build.isoImage;
          windows-bootstrapIso = callPackage ./packages/windows { };
          # nix build ./nix#windows-bootstrapIso -o unattend-win10-iot-ltsc-vrt.iso

          bcompare = (callPackage ./packages/bcompare.nix { }).overrideAttrs {
            #? sorry, I can't buy this software right now (and trial doesn't work)
            #? https://gist.github.com/rise-worlds/5a5917780663aada8028f96b15057a67?permalink_comment_id=5168755#gistcomment-5168755
            postFixup = ''
              sed -i "s/AlPAc7Np1/AlPAc7Npn/g" $out/lib/beyondcompare/BCompare
            '';
          };

          kompas3d = kdePackages.callPackage ./packages/kompas3d { };
          kompas3d-fhs = callPackage ./packages/kompas3d/fhs.nix { };
          grdcontrol = callPackage ./packages/grdcontrol.nix { };

        }
        // flattenPkgs (
          lib.filesystem.packagesFromDirectoryRecursive {
            inherit callPackage;
            directory = ./packages/auto;
          }
        );
      legacyPackages.${system} = with pkgs; {
        #! nix flake check: need to update patches everytime
        telegram-desktop-patched = callPackage ./packages/telegram-desktop-patched.nix { };
        ayugram-desktop-patched = callPackage ./packages/telegram-desktop-patched.nix {
          telegram-desktop-client = ayugram-desktop;
        };

        #! nix flake check: local src
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

        #! nix flake check: openwrt hash drifts
        # nix build ./nix#openwrt
        # or if hash mismatch
        # nix run <locally cloned nix-openwrt-imagebuilder>#generate-hashes <openwrt version>
        # nix build --override-input openwrt-imagebuilder <locally cloned nix-openwrt-imagebuilder> ./nix#openwrt
        openwrt-xiaomi_ax3600 = import ./packages/openwrt/xiaomi_ax3600.nix { inherit pkgs inputs; };
        openwrt-tplink_archer-c50-v4 = (
          import ./packages/openwrt/tplink_archer-c50-v4.nix { inherit pkgs inputs; }
        );
        openwrt-dewclaw-env = callPackage inputs.dewclaw {
          configuration = import ./packages/openwrt/dewclaw.nix;
        };
      };
      formatter.${system} = with pkgs; nixfmt-tree;
    };
}
