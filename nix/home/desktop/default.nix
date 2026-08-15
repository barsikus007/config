{ pkgs, config, ... }@args:
let
  defaultSession = args.osConfig.services.displayManager.defaultSession or null;
in
{
  imports = [
    ../gui/terminal.nix
    ./environment/launcher.nix
  ];
  home.packages = pkgs.callPackage ../../shared/shell-scripts.nix { inherit config defaultSession; };
}
