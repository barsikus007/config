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
          #? last commit have KVMFR_VERSION 23
          # rev = "d3d1d48e97c47416e2e04662573d7484540e4a0a";
          # hash = "sha256-lsY/pT2Fsf2brS014fmUvRQX9q/EHDxXWZvlwFm5jgY=";
          #? last commit with KVMFR_VERSION 20
          rev = "0d2dc2694ee1cec91d3741aac7d3da210197631a";
          hash = "sha256-7ODEsVfOsIrJ+GwV6l2Hdj7WkRAkEzwkOnbfcWHXbsc=";
          #? last byte comparable ABI with my current host commit
          # rev = "c9845d3453e5329def118d0a704a956f373d0150";
          # hash = "sha256-N3j6SItdKQeHfz5sQYYCTqiHOTecO2m8vwm5vIDSCvU=";
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
