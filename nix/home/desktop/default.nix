{ pkgs, ... }:
{
  imports = [
    ../gui/terminal.nix
    ./environment/launcher.nix
  ];
  home.packages = (import ../../shared/shell-scripts.nix { inherit pkgs; });
}
