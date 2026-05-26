{ pkgs, ... }:
{
  programs.bat = {
    enable = true;
    config.theme = "Coldark-Dark";
    extraPackages = with pkgs.bat-extras; [ batgrep ];
  };
  programs.zsh = {
    shellAliases = {
      batsh = "bat --language=sh";
      cat = "bat --style=plain";
      ccat = ''\command cat'';
    };
  };
  programs.lesspipe.enable = true;
  home.sessionVariables = {
    PAGER = "bat";
    LESS = "--mouse";
  };
}
