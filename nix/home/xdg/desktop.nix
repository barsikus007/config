{ pkgs, ... }:
{
  imports = [
    ./mime/apps.nix
    ./mime/remove.nix
  ];
  #? handlr redirects URLs to some apps and only then to browsers
  home.packages = with pkgs; [ handlr-regex ];

  xdg.userDirs.enable = true;
}
