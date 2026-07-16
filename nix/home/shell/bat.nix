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
    #? https://github.com/sharkdp/bat#highlighting---help-messages
    envExtra = /* shell */ ''
      alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
      alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
    '';
  };
  programs.lesspipe.enable = true;
  home.sessionVariables = {
    PAGER = "bat";
    LESS = "--mouse";
  };
}
