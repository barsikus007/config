{ lib, username, ... }:
{
  imports = [
    ../shared/options.nix

    ./git.nix
  ];
  home = {
    #? https://nix-community.github.io/home-manager/release-notes.xhtml
    stateVersion = lib.mkDefault "26.05";

    inherit username;
    homeDirectory = lib.mkDefault "/home/${username}";

    preferXdgDirectories = true;
  };
  xdg.enable = true;
}
