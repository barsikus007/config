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
    "graalvm-oracle"

    "code"
    "vscode"
    "discord"
    "obsidian"
    "parsec-bin"
    "microsoft-edge"

    "bcompare"
    "davinci-resolve-studio"
  ];
in
import inputs.nixpkgs {
  inherit system;
  overlays = [
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit prev;
        system = prev.system;
        config.allowUnfreePredicate = pkg: builtins.elem (inputs.nixpkgs-unstable.lib.getName pkg) paidApps;
      };
      previous = import inputs.nixpkgs-previous {
        inherit prev;
        system = prev.system;
        config.allowUnfreePredicate = pkg: builtins.elem (inputs.nixpkgs-previous.lib.getName pkg) paidApps;
      };
    })
  ];
  config.allowUnfreePredicate = pkg: builtins.elem (inputs.nixpkgs.lib.getName pkg) paidApps;
}
