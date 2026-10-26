{ lib, inputs, ... }:
let
  #! харам, платные приложения
  paidApps = [
    "nvidia-x11"
    "nvidia-settings"

    "steam"
    "steam-unwrapped"
    "lsfg-vk" # bottles dep

    "7zip-zstd"
    "uasm" # 7zz unfree dep
    "unrar"
    "corefonts"

    # "blender"
    # "cuda_cudart"
    # "cuda_nvcc"
    # "cuda_cccl"
    # "libcublas"
    # "cuda_nvrtc"
    # "libcusolver"
    # "libnvjitlink"
    # "libcusparse"

    #? for firefox
    # "libcurand"
    # "libcufft"
    # "cudnn"
    # "libnpp"

    # "cuda_nvml_dev"

    "vscode"
    "discord"
    "bcompare"
    "obsidian"
    "xnconvert"
    "parsec-bin"
    "antigravity-cli"

    "mprint"
    "hytale-launcher"

    # "grdcontrol"
    # "kompas3d-v24-full"
  ];
  allowUnfreePredicateGen = pkgs: pkg: builtins.elem (pkgs.lib.getName pkg) paidApps;

  autoFlakePackagesOverlay = _final: prev: {
    flakePackages =
      let
        flattenPkgs = prev.lib.concatMapAttrs (
          name: v:
          if prev.lib.isDerivation v then
            { ${name} = v; }
          else if prev.lib.isAttrs v then
            flattenPkgs v
          else
            { }
        );
      in
      flattenPkgs (
        prev.lib.filesystem.packagesFromDirectoryRecursive {
          inherit (prev) callPackage;
          directory = ../packages/auto;
        }
      );
  };
in
{
  nixpkgs.config.allowUnfreePredicate = allowUnfreePredicateGen inputs.nixpkgs;

  nixpkgs.overlays = [
    autoFlakePackagesOverlay
    # TODO: unstable
    (_final: prev: {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (pyFinal: pyPrev: {
          fastmcp-slim = pyPrev.fastmcp-slim.override {
            mcp = pyFinal.mcp_1;
          };
        })
      ];
    })
    (
      #? map "nixpkgs-*" flake inputs as attrs of pkgs
      _final: prev:
      builtins.mapAttrs
        (
          _pkgsName: pkgsInput:
          import pkgsInput {
            system = prev.stdenv.hostPlatform.system;
            config.allowUnfreePredicate = allowUnfreePredicateGen pkgsInput;
          }
        )
        (
          #! not the `|>` pipe operator: pedantix' parser rejects it as invalid nix
          lib.pipe inputs [
            (lib.attrsets.filterAttrs (inputName: _: lib.strings.hasPrefix "nixpkgs-" inputName))
            (lib.attrsets.mapAttrs' (
              inputName: input: {
                name = lib.strings.removePrefix "nixpkgs-" inputName;
                value = input;
              }
            ))
          ]
        )
    )
  ];
}
