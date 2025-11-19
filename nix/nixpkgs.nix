{ system, inputs }:
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

    "xow_dongle-firmware"
  ];
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
        {
          previous = inputs.nixpkgs-previous;
          # master = inputs.nixpkgs-master;
        }
    )
  ];
  config.allowUnfreePredicate = pkg: builtins.elem (inputs.nixpkgs.lib.getName pkg) paidApps;
}
