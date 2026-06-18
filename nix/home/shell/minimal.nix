{
  lib,
  pkgs,
  config,
  flakePath,
  ...
}:
#! 90Mb
let
  aliases = import ./aliases.nix { inherit lib pkgs flakePath; };
  sharedAliases = aliases.sharedAliases // aliases.nixAliases;
  inherit (aliases) zshAliases;
in
{
  imports = [
    ./bat.nix
    ./yazi.nix
  ];

  xdg.configFile."shell/".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/shell/";
  home.shellAliases = sharedAliases;
  home.packages = with pkgs; [ zsh-completions ];
  programs.zsh = {
    enable = true;
    shellAliases = zshAliases;
    history = {
      #? cp ~/.config/zsh/.zsh_history ~/Sync/backup/.zsh_history_$(hostname)_$(date +%Y-%m-%d'_'%H_%M_%S).bak
      size = 100000;
    };
    autocd = true;
    # enableCompletion = true; #? default
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    plugins = with pkgs; [
      {
        name = "zsh-fzf-tab";
        src = zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];
    defaultKeymap = "emacs";
    envExtra = /* shell */ ''
      #! XDG_CONFIG_HOME is unset this early in .zshenv
      for file in "''${XDG_CONFIG_HOME:-$HOME/.config}"/shell/*.sh; do
        source "$file"
      done
    '';
    initContent = builtins.readFile ../../.config/zsh/.zshrc;
  };
  programs.bash = {
    enable = true;
    historySize = 100000;
    historyControl = [ "ignoreboth" ];
    initExtra = /* shell */ ''
      for file in "$XDG_CONFIG_HOME"/shell/*.sh; do
        source "$file"
      done
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    options = [ "--cmd cd" ];
  };

  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g mouse on
    '';
  };
  programs.zellij = {
    enable = true;
    settings = {
      scroll_buffer_size = 100000;
      default_mode = "locked";
      show_startup_tips = false;
    };
  };

  programs.starship = {
    enable = true;
    # settings = builtins.fromTOML (builtins.readFile ../../.config/starship.toml);
    settings = lib.mkForce { };
  };
  xdg.configFile."starship.toml".source = # TODO stylix conflict
    lib.mkForce (config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/starship.toml");
  xdg.configFile."starship/starship.bash".source = ../../.config/starship/starship.bash;

  programs.lazygit.enable = true;
  programs.btop = {
    enable = true;
    settings = {
      proc_tree = true;
    };
  };
}
