{ lib, pkgs, ... }:

{
  programs.bat = {
    enable = true;
    config = {
      theme = "Coldark-Dark";
    };
    extraPackages = with pkgs.bat-extras; [
      batman
      batgrep
    ];
  };
  programs.zsh = {
    shellAliases = {
      batsh = "bat --language=sh";
      cat = "bat --style=plain";
      ccat = ''\command cat'';
    };
    initContent = ''eval "$(batman --export-env)"'';
  };
  home.sessionVariables.MANPAGER = lib.mkForce "";
  programs.lesspipe.enable = true;
  home.sessionVariables = {
    PAGER = "bat";
    LESS = "--mouse";
  };
}
