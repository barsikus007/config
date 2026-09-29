{ pkgs, ... }:
{
  programs.looking-glass-client = {
    enable = true;
    settings = {
      input = {
        escapeKey = "KEY_RIGHTALT";
      };
      win = {
        fullScreen = true;
        showFPS = true;
      };
    };
    package = pkgs.looking-glass-client.overrideAttrs (
      previousAttrs:
      let
        #? https://github.com/gnif/LookingGlass/commits/master/
        #? KVMFR_VERSION 34: https://github.com/gnif/LGProtocol/blob/master/include/LGProtocol/KVMFR.h#L42
        rev = "236efcb155f952f5d7d9fcd5891a3060ad254e68";
        hash = "sha256-NAfV4Z0RZp2IGBzVAFysm53aGMEReT03RIN+45TveUU=";
      in
      {
        version = "B7-g${builtins.substring 0 10 rev}";

        src = pkgs.fetchFromGitHub {
          inherit rev hash;
          owner = "gnif";
          repo = "LookingGlass";
          fetchSubmodules = true;
        };

        patches = [ ];

        buildInputs =
          previousAttrs.buildInputs
          ++ (with pkgs; [
            fuse3
            libunwind
            elfutils
            zstd
            xorg.libxcb
            usbredir
            libdecor
          ]);
      }
    );
  };
}
