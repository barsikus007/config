{ lib, pkgs, ... }:
#! 970Mb
{
  imports = [
    ./minimal.nix
    #! 9Mb
    ../modules/shell
    #! 13Mb
    ../modules/shell/zsh.nix
  ];

  #! 216Mb
  environment.systemPackages =
    [ ]
    ++ import ../shared/lists/00_essential.nix { inherit pkgs; }
    ++ import ../shared/lists/01_base.nix { inherit pkgs; };

  #! 150Mb
  programs.yazi.enable = true;

  #! 40Mb
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
  environment.variables.VISUAL = "nvim";

  # TODO: unstable: https://github.com/NixOS/nixpkgs/pull/361716
  # boot.kernelPackages = lib.mkDefault (with pkgs; linuxPackages_latest);
  boot.kernelPackages = lib.mkDefault (with pkgs; linuxPackages_6_18);

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
