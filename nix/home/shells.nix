{
  pkgs,
  config,
  flakePath,
  ...
}:

let
  baseAliases = {
    editor = "nano";
    grp = "grep -Fin -C 7";
    c = "clear";
    h = "history";
    hf = "h | grp";
    ls = "ls --group-directories-first --color=auto --hyperlink";
    l = "ls -CFbh";
    ll = "ls -laFbgh";
    sshe = "editor ~/.ssh/config";
    nv = "editor $(fzf)";
    nvf = "editor $(find \"/\" | fzf)";
    nvs = "editor $(rg -n . | fzf | awk -F: '{print \"+\"$2,$1}')";
    "1ip" = "wget -qO - icanhazip.com";
    "2ip" = "curl 2ip.ru";
    cu = "cd ${flakePath} && git pull && cd -";
    diff = "diff --color";
    #? https://www.cyberciti.biz/faq/unix-linux-check-if-port-is-in-use-command/
    open-ports = "sudo lsof -i -P -n | grep LISTEN";
  };
  # TODO: non ported
  dockerAliases = {
    lzd = "lazydocker";
    dsp = "docker system prune";
    dspa = "dsp --all";
    dc = "docker compose";
    dcu = "dc up -d";
    dcub = "dcu --build";
    dcuo = "dcu --remove-orphans";
    dcup = "dc -f compose.prod.yaml up -d";
    dcp = "dc ps";
    dcs = "dc stop";
    dcd = "dc down";
    dcl = "dc logs";
    dcr = "dc restart";
    dce = "dc exec -it";
    cdl = "sudo sh -c \"truncate -s 0 /var/lib/docker/containers/*/*-json.log\"";
  };
  # TODO: non ported
  pythonAliases = {
    pipi = "uv pip install -r requirements.txt || uv pip install -r pyproject.toml";
    pyvcr = "uv venv --allow-existing && source .venv/bin/activate && pipi";
    pyv = "source .venv/bin/activate || pyvcr";
    pyt = "ptpython";
    pyta = "pyt --asyncio";
  };
  wgAliases = {
    wgu = "sudo systemctl start wg-quick-awg0";
    wgs = "systemctl status wg-quick-awg0";
    wgd = "sudo systemctl stop wg-quick-awg0";
  };
  otherAliases = {
    gdu = "gdu -I ^/mnt";
    zps = "zpool status -v";
    sex = "explorer.exe .";
    lzg = "lazygit";
    yt-dlpa = "yt-dlp -N 16 -R inf";
  };
  ezaAliases = {
    l = "eza -F -bghM --smart-group --group-directories-first --color=auto --color-scale --icons=always --no-quotes --hyperlink";
    ll = "eza -F -labghM --smart-group --group-directories-first --color=auto --color-scale --icons=always --no-quotes --hyperlink";
  };
  nvimAliases = {
    editor = "nvim";
    nv = "nvim +'Telescope find_files hidden=true'";
    nvf = "nvim +'Telescope find_files hidden=true cwd=/'";
    nvs = "nvim +'Telescope live_grep hidden=true'";
  };
  batAliases = {
    cat = "bat";
  };
  nixAliases =
    let
      inherit flakePath;
    in
    {
      iusenixbtw = "fastfetch";
      nu = "nix flake update --flake ${flakePath}";
      # n = "home-manager switch --flake ${flakePath}";
      n = "nh home switch ${flakePath}";
      # nn = "nixos-rebuild switch --flake ${flakePath}";
      nn = "nh os switch ${flakePath}";
      # nd = "nix-collect-garbage -d";
      nd = "nh clean all --keep 5 --keep-since 4d";
      nr = "nixos-rebuild repl --flake ${flakePath}";
      nrr = "nh os repl ${flakePath}";
      ne = "editor ${flakePath}";
      ndiff = "nvd diff ~/.local/state/nix/profiles/$(command ls -t ~/.local/state/nix/profiles | fzf) ~/.local/state/nix/profiles/home-manager";
      nndiff = "nvd diff /nix/var/nix/profiles/$(command ls -t /nix/var/nix/profiles/ | fzf) /nix/var/nix/profiles/system";
      nix-shell = "nix-shell --run zsh";
      ns = "nix-shell -p";
    };
  sharedAliases =
    baseAliases
    // dockerAliases
    // pythonAliases
    // wgAliases
    // otherAliases
    // ezaAliases
    // nvimAliases
    // batAliases
    // nixAliases;
  zshAliases = {
    "?" = "type_colored_and_nix_truncate";
    "??" = "type_colored";
  };
in
{
  home.sessionVariables = {
    PAGER = "bat";
    LESS = "--mouse";
  };
  xdg.configFile."shell/functions.sh".source =
    config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/shell/functions.sh";
  # TODO: finer way to do it
  xdg.configFile."shell/wifite.sh".source =
    config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/shell/wifite.sh";
  xdg.configFile."shell/g14.sh".source =
    config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/shell/g14.sh";
  xdg.configFile."shell/setup.sh".source =
    config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/shell/setup.sh";
  programs.zsh = {
    enable = true;
    shellAliases = sharedAliases // zshAliases;
    history = {
      size = 100000;
    };
    autocd = true;
    enableCompletion = true; # true by default
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    plugins = [
      {
        name = "zsh-fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];
    envExtra = ''
      source "$XDG_CONFIG_HOME"/shell/g14.sh
      # source ~/.zshrc
    '';
    initContent = # /* shell */ comment for tree-sitter
      ''
        autoload -Uz select-word-style
        select-word-style bash

        bindkey -e
        # home
        #bindkey "^[[H"    beginning-of-line
        bindkey "^[OH"    beginning-of-line
        # end
        #bindkey "^[[F"    end-of-line
        bindkey "^[OF"    end-of-line

        # page up/down
        bindkey "^[[5~"   beginning-of-history
        bindkey "^[[6~"   end-of-history

        # alt + left/right
        bindkey "^[[1;3D" backward-word
        bindkey "^[[1;3C" forward-word
        # ctrl + left/right
        bindkey "^[[1;5D" backward-word
        bindkey "^[[1;5C" forward-word

        # delete
        bindkey "^[[3~"   delete-char
        # alt + backspace
        bindkey "^[^H"    backward-kill-word
        # alt + delete
        bindkey "^[[3;3~" delete-word
        # ctrl + backspace
        bindkey "^H"      backward-kill-word
        # ctrl + delete
        bindkey "^[[3;5~" delete-word

        source "$XDG_CONFIG_HOME"/shell/functions.sh
      '';
  };
  programs.bash = {
    enable = true;
    shellAliases = sharedAliases;
    historySize = 100000;
    historyControl = [ "ignoreboth" ];
    initExtra = ''
      source "$XDG_CONFIG_HOME"/shell/functions.sh
    '';
  };
  programs.fish = {
    enable = true;
    shellAliases = sharedAliases;
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
  programs.bat = {
    enable = true;
    config = {
      theme = "Coldark-Dark";
    };
    # TODO: batman, batpipe and check other extra stuff
    extraPackages = with pkgs.bat-extras; [
      batdiff
      batman
      batpipe
      batgrep
      batwatch
    ];
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
    };
  };
  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ../.config/starship.toml);
  };
  xdg.configFile."starship/starship.bash".source = ../.config/starship/starship.bash;
  programs.yazi = {
    enable = true;
    settings = {
      mgr.show_hidden = true;
    };
    plugins = {
      smart-enter = pkgs.yaziPlugins.smart-enter;
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
  };
  programs.lazygit.enable = true;
  programs.btop = {
    enable = true;
    settings = {
      proc_tree = true;
    };
  };
}
