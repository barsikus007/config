{ pkgs, ... }:
{
  programs.looking-glass-client = {
    enable = true;
    settings = {
      input = {
        escapeKey = "KEY_RIGHTALT";
      };
      win = {
        # position = "10x10";
        size = "2560x1440";
        fullScreen = true;
        showFPS = true;
      };
    };
    package =
      with pkgs;
      looking-glass-client.overrideAttrs (
        let
          # https://github.com/gnif/LookingGlass/commits/master/
          # https://github.com/gnif/LookingGlass/compare/<ref>...gnif%3ALookingGlass%3Amaster
          rev = "d3d1d48e97c47416e2e04662573d7484540e4a0a";
          hash = "sha256-lsY/pT2Fsf2brS014fmUvRQX9q/EHDxXWZvlwFm5jgY=";
        in
        {
          version = "B7-g${builtins.substring 0 10 rev}";

          src = fetchFromGitHub {
            inherit rev hash;
            owner = "gnif";
            repo = "LookingGlass";
            fetchSubmodules = true;
          };
        }
      );
  };
}
