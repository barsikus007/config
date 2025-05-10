{ system, inputs }:
import inputs.nixpkgs {
  inherit system;
  overlays = [
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit prev;
        system = prev.system;
        config.allowUnfree = true;
      };
    })
  ];
  # харам, платные приложения
  config.allowUnfreePredicate =
    pkg:
    builtins.elem (inputs.nixpkgs.lib.getName pkg) [
      "nvidia-x11"
      "nvidia-settings"
      "nvidia-persistenced"

      "steam"
      "steam-unwrapped"
      "steam-original"
      "steam-run"

      "unrar"

      "discord"
      "obsidian"
      "parsec-bin"
      "microsoft-edge"

      "bcompare"
      "davinci-resolve-studio"
    ];
}
