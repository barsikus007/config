{
  lib,
  pkgs,
  config,
  flakePath,
  ...
}:

let
  baseAliases = {
    editor = "nano";
    grep = "grep --color=auto";
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
    "3ip" = "curl -so- ipinfo.io | jq";
    cu = "cd ${flakePath} && git pull && cd -";
    #? nix have ip with prebuilt color, alias brokes autocmpletion
    # ip = "ip --color";
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
    wgr = "sudo systemctl restart wg-quick-awg0";
    wgw = "sudo watch -c script -q -c awg show";
  };
  otherAliases = {
    gdu = "gdu -I ^/mnt";
    zps = "zpool status -v";
    sex = "explorer.exe .";
    lzg = "lazygit";
    yt-dlpa = "yt-dlp --concurrent-fragments=16 --retries=inf";
    aria2ca = "aria2c --split=16 --max-connection-per-server=16 --continue";
  };
  ezaAliases = {
    l = "eza -F -bghM --smart-group --group-directories-first --color=auto --color-scale --icons=always --no-quotes --hyperlink";
    ll = "eza -F -labghM --smart-group --group-directories-first --color=auto --color-scale --icons=always --no-quotes --hyperlink";
    lls = ''\command ls'';
  };
  nvimAliases = {
    editor = "nvim";
    nv = "nvim +'Telescope find_files hidden=true'";
    nvf = "nvim +'Telescope find_files hidden=true cwd=/'";
    nvs = "nvim +'Telescope live_grep hidden=true'";
  };
  nixAliases =
    let
      inherit flakePath;
    in
    {
      iusenixbtw = "fastfetch";
      nu = "nix flake update --flake ${flakePath}";
      nuu = "nix flake update nixpkgs --override-input nixpkgs nixpkgs/$(nixos-version --hash)";
      n = "nh home switch ${flakePath}";
      nn = "nh os switch ${flakePath}";
      nnn = "sudo true && nn && notify-send 'System build success' && exec $SHELL || notify-send 'System build failed'";
      nd = "nh clean all";
      nr = "nix repl --file ${flakePath}/repl.nix";
      nrr = "nh home repl ${flakePath}";
      nrrr = "nixos-rebuild repl --flake ${flakePath}";
      ne = "editor ${flakePath}";
      ndiff = "${lib.getExe pkgs.nvd} diff ~/.local/state/nix/profiles/$(command ls -t ~/.local/state/nix/profiles | fzf) ~/.local/state/nix/profiles/home-manager";
      nndiff = "${lib.getExe pkgs.nvd} diff /nix/var/nix/profiles/$(command ls -t /nix/var/nix/profiles/ | fzf) /nix/var/nix/profiles/system";
      nix-shell = "nix-shell --run zsh";
      ns = "nix-shell -p";
      nss = "nix_shell_exec";
      ncode = "code --reuse-window $(nix eval -f '<nixpkgs>' path)/pkgs/top-level/all-packages.nix";
    };
  sharedAliases =
    baseAliases
    // dockerAliases
    // pythonAliases
    // wgAliases
    // otherAliases
    // ezaAliases
    // nvimAliases
    // nixAliases;
  zshAliases = {
    "?" = "type_colored_and_nix_truncate";
    "??" = "type_colored";
  };
in
{
  imports = [
    ./bat.nix
  ];
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
    '';
    initContent = # /* shell */ comment for tree-sitter
      ''
        alias -s ts="bun"
        alias -s py="python"

        autoload -Uz select-word-style
        select-word-style bash

        bindkey -e
        # home
        bindkey "^[[H"    beginning-of-line
        #? probably, for WSL (or wt.exe), but works on wezterm too
        bindkey "^[OH"    beginning-of-line
        # end
        bindkey "^[[F"    end-of-line
        #? probably, for WSL (or wt.exe), but works on wezterm too
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
