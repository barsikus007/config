{ pkgs, ... }:

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
      cat = "bat --style=plain";
      ccat = ''\command cat'';
    };
    initContent = ''eval "$(batman --export-env)"'';
  };
  programs.lesspipe.enable = true;
  home.sessionVariables = {
    PAGER = "bat";
    LESS = "--mouse";
  };
}
