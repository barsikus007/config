{ pkgs, ... }:
{
  imports = [
    ../gui/terminal.nix
    ./environment/launcher.nix
  ];
  home.packages = (import ../../shared/shell-scripts.nix { inherit pkgs; });
  services.cliphist = {
    enable = true;
    #! https://github.com/YaLTeR/wl-clipboard-rs/issues/5
    #! https://github.com/bugaevc/wl-clipboard/issues/268
  };
  home.file.".face.icon".source = builtins.fetchurl {
    url = "https://github.com/barsikus007.png";
    sha256 = "sha256-ifkRxN8PTXOp7zkM8NcEWptT7scvMVkGZlcUs6B+0Dk=";
  };
}
