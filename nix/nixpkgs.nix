{
  inputs,
  system,
  nixpkgs ? inputs.nixpkgs,
  overlays ? [ ],
}:
let
  #! харам, платные приложения
  paidApps = [
    "nvidia-x11"
    "nvidia-settings"

    "steam"
    "steam-unwrapped"

    "7zz"
    "uasm" # ? 7zz unfree dep
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
  inherit (nixpkgs) lib;
in
import nixpkgs {
  inherit system;
  overlays = [
    (
      _final: _prev:
      builtins.mapAttrs
        (
          _pkgsName: pkgsInput:
          import pkgsInput {
            inherit system;
            config.allowUnfreePredicate = allowUnfreePredicateGen pkgsInput;
          }
        )
        (
          #! not the `|>` pipe operator: pedantix' parser rejects it as invalid nix
          lib.pipe inputs [
            (nixpkgs.lib.attrsets.filterAttrs (inputName: _: lib.strings.hasPrefix "nixpkgs-" inputName))
            (lib.attrsets.mapAttrs' (
              inputName: input: {
                name = lib.strings.removePrefix "nixpkgs-" inputName;
                value = input;
              }
            ))
          ]
        )
    )
  ]
  ++ overlays;
  config.allowUnfreePredicate = allowUnfreePredicateGen nixpkgs;
}
