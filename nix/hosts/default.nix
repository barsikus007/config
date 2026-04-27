{ pkgs, ... }:
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
  programs.nano.enable = false;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
  environment.variables.VISUAL = "nvim";

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
