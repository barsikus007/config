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
    (final: prev: {
      previous = import inputs.nixpkgs-previous {
        inherit prev;
        system = prev.system;
        config.allowUnfreePredicate = pkg: builtins.elem (inputs.nixpkgs-previous.lib.getName pkg) paidApps;
      };
    })
  ];
  config.allowUnfreePredicate = pkg: builtins.elem (inputs.nixpkgs.lib.getName pkg) paidApps;
}
