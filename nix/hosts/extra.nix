{ pkgs, ... }:
#! 970Mb
{
  #! 470Mb
  imports = [
    ./.
    ../modules/locale.nix
  ];

  #! 150Mb
  fonts.packages = with pkgs; [
    cascadia-code
  ];
  fonts.fontconfig.defaultFonts.monospace = [
    "Cascadia Code NF"
  ];

  #! 350Mb
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}
