{ pkgs, ... }:
#! 970Mb
{
  imports = [
    ./minimal.nix
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

  # TODO: unstable: https://github.com/NixOS/nixpkgs/pull/488627, https://github.com/NixOS/nixpkgs/pull/361716
  # boot.kernelPackages = with pkgs; linuxPackages_latest;

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

  #! 13Mb
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    histSize = 100000;
    shellInit = ''
      # Disable zsh's newuser startup script that prompts you to create
      # a ~/.z* file if missing
      zsh-newuser-install() { :; }
    '';
    interactiveShellInit = ''
      #! add from home config
      bindkey -e
    ''
    + builtins.readFile ../.config/zsh/.zshrc;
  };
}
