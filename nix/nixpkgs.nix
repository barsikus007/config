{
  system,
  inputs,
  overlays ? [ ],
}:
let
  # харам, платные приложения
  paidApps = [
    "nvidia-x11"
    "nvidia-settings"
    "nvidia-persistenced"

    "steam"
    "steam-unwrapped"
    "steam-original"
    "steam-run"

    "7zz"
    "unrar"
    "corefonts"
    "graalvm-oracle"

    "blender"
    "cuda_cudart"
    "cuda_nvcc"
    "cuda_cccl"

    "code"
    "vscode"
    "discord"
    "obsidian"
    "parsec-bin"
    "microsoft-edge"

    "mprint"
    "bcompare"
    "grdcontrol"
    "kompas3d-v24-full"
    "davinci-resolve-studio"
  ];
  lib = inputs.nixpkgs.lib;
in
import inputs.nixpkgs {
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
          inputs
          |> inputs.nixpkgs.lib.filterAttrs (inputName: _: inputName |> lib.strings.hasPrefix "nixpkgs-")
          |> lib.attrsets.mapAttrs' (
            inputName: input: {
              name = "${inputName |> lib.strings.removePrefix "nixpkgs-"}";
              value = input;
            }
          )
        )
    )
  ] ++ overlays;
  config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) paidApps;
}
