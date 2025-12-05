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
          rev = "53bfb6547f2b7abd6c183192e13a57068c1677ea";
          hash = "sha256-SakFCEXPsJW3zmNpmklK8ZCGpcJzJ/4v7TJDpjWqVeA=";
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
