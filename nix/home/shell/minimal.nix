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

  programs.nix-your-shell = {
    enable = true;
    nix-output-monitor.enable = true;
  };

  xdg.configFile."shell/".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/shell/";
  xdg.configFile."scripts/".source =
    config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/scripts/";
  home.sessionPath = [ "${config.xdg.configHome}/scripts" ];
  home.shellAliases = sharedAliases;
  home.packages = with pkgs; [ zsh-completions ];
  #? interpreter for ~/.config/scripts/*.ts, #? +41M on disk (97M logical)
  programs.bun.enable = true;
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
    envExtra = ''
      #! XDG_CONFIG_HOME is unset this early in .zshenv
      for file in "''${XDG_CONFIG_HOME:-$HOME/.config}"/shell/*.sh; do
        source "$file"
      done
      #? generated zsh completions for scripts/*.ts, compinit picks them up in .zshrc
      fpath+=("''${XDG_CONFIG_HOME:-$HOME/.config}/scripts/completions")
    '';
    # TODO: zshrc is duplicated with system modules/shell/zsh.nix
    initContent = builtins.readFile ../../.config/zsh/.zshrc;
  };
  programs.bash = {
    enable = true;
    historySize = 100000;
    historyControl = [ "ignoreboth" ];
    initExtra = ''
      for file in "$XDG_CONFIG_HOME"/shell/*.sh; do
        source "$file"
      done
    '';
  };

  programs.fd.enable = true;
  programs.fzf.enable = true;
  programs.ripgrep.enable = true;
  programs.zoxide = {
    enable = true;
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

  programs.starship.enable = true;
  xdg.configFile."starship.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/starship.toml";
  xdg.configFile."starship/starship.bash" = {
    source = ../../.config/starship/starship.bash;
    executable = true;
  };

  programs.lazygit.enable = true;
  programs.btop = {
    enable = true;
    package = pkgs.btop.override {
      cudaSupport = pkgs.stdenv.hostPlatform.isx86_64;
      rocmSupport = pkgs.stdenv.hostPlatform.isx86_64;
    };
    settings = {
      proc_tree = true;
    };
  };
}
