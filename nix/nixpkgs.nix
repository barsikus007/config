{
  system,
  inputs,
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

    "blender"
    "cuda_cudart"
    "cuda_nvcc"
    "cuda_cccl"

    "vscode"
    "discord"
    "obsidian"
    "xnconvert"
    "parsec-bin"
    "antigravity-cli"

    "mprint"
    "bcompare"
    "grdcontrol"
    "hytale-launcher"
    "kompas3d-v24-full"
    "davinci-resolve-studio"
  ];
  lib = nixpkgs.lib;
in
import nixpkgs {
  inherit system;
  overlays = [
    (
      _: prev:
      builtins.mapAttrs
        (
          pkgsName: pkgsInput:
          import pkgsInput {
            inherit system;
            config.allowUnfreePredicate = pkg: builtins.elem (pkgsInput.lib.getName pkg) paidApps;
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
  config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) paidApps;
}
