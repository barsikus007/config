{ pkgs, ... }:
{
  users.defaultUserShell = with pkgs; zsh;
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
    + builtins.readFile ../../.config/zsh/.zshrc;
  };
}
