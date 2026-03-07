{ pkgs, ... }:
#! 720Mb
{
  imports = [
    ./minimal.nix
  ];

  #! 216Mb
  environment.systemPackages =
    [ ]
    ++ import ../shared/lists/00_essential.nix { inherit pkgs; }
    ++ import ../shared/lists/01_base.nix { inherit pkgs; };

  environment.variables = rec {
    EDITOR = "nvim";
    VISUAL = EDITOR;
  };

  # TODO: unstable: https://github.com/NixOS/nixpkgs/pull/488627, https://github.com/NixOS/nixpkgs/pull/361716
  # boot.kernelPackages = with pkgs; linuxPackages_latest;
  boot.kernelPackages = with pkgs; linuxPackages_6_18;

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
