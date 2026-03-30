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
  ];
  home.packages = with pkgs; [ zsh-completions ];
  # TODO: finer way to do it
  xdg.configFile."shell/".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/shell/";
  programs.zsh = {
    enable = true;
    shellAliases = sharedAliases // zshAliases;
    history = {
      #? cp ~/.config/zsh/.zsh_history ~/Sync/backup/.zsh_history_$(date +%Y-%m-%d'_'%H_%M_%S).bak
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
      # syntax: shell
      for file in "$XDG_CONFIG_HOME"/shell/*.sh; do
        source "$file"
      done
    '';
    initContent = builtins.readFile ../../.config/zsh/.zshrc;
  };
  programs.bash = {
    enable = true;
    shellAliases = sharedAliases;
    historySize = 100000;
    historyControl = [ "ignoreboth" ];
    initExtra = ''
      # syntax: shell
      for file in "$XDG_CONFIG_HOME"/shell/*.sh; do
        source "$file"
      done
    '';
  };
  # programs.fish = {
  #   enable = true;
  #   shellAliases = sharedAliases;
  # };
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
  programs.yazi = {
    enable = true;
    settings = {
      mgr.show_hidden = true;
      plugin.prepend_previewers = [
        {
          name = "*.csv";
          run = "rich-preview";
        } # for csv files
        {
          name = "*.md";
          run = "rich-preview";
        } # for markdown (.md) files
        {
          name = "*.rst";
          run = "rich-preview";
        } # for restructured text (.rst) files
        {
          name = "*.ipynb";
          run = "rich-preview";
        } # for jupyter notebooks (.ipynb)
        {
          name = "*.json";
          run = "rich-preview";
        } # for json (.json) files
      ];
    };
    plugins = with pkgs.yaziPlugins; {
      smart-enter = smart-enter;
      rich-preview = rich-preview;
    };
    #? https://github.com/sxyazi/yazi/tree/shipped/yazi-config/preset
    keymap = {
      mgr = {
        prepend_keymap = [
          {
            on = "<F2>";
            run = "rename";
            desc = "Rename file or folder";
          }
          #? https://github.com/sxyazi/yazi/issues/1758#issuecomment-2407103834
          {
            on = "<Enter>";
            run = "plugin --sync smart-enter";
            desc = "Enter the child directory, or open the file";
          }
        ];
      };
    };
    #? https://github.com/sxyazi/yazi/blob/157156b5b8f36db15b2ba425c7d15589039a9e1e/yazi-plugin/preset/components/linemode.lua#L25
    initLua = ''
      --[[
      # syntax: lua
      ]]
      function strip_date_year(time_to_format)
        local time = math.floor(time_to_format or 0)
        if time == 0 then
          return ""
        elseif os.date("%Y", time) == os.date("%Y") then
          return os.date("%m-%d %H:%M", time)
        else
          return os.date("%Y-%m-%d", time)
        end
      end
      function Linemode:btime()
        return strip_date_year(self._file.cha.btime)
      end
      function Linemode:mtime()
        return strip_date_year(self._file.cha.mtime)
      end
    '';
  };
  programs.lazygit.enable = true;
  programs.btop = {
    enable = true;
    settings = {
      proc_tree = true;
    };
  };
}
