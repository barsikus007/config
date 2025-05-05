{ pkgs, flakePath, ... }:

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
    cu="cd ${flakePath} && git pull && cd -";
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
    gdu = "gdu -I ^/nix";
    zps = "zpool status -v";
    sex = "explorer.exe .";
    lzg = "lazygit";
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
  # ROG G14 specific aliases
  # TODO: if asus
  # TODO install media and conf file
  # TODO: non ported
  rogG14Aliases = {
    animeclr = "asusctl anime -E false > /dev/null";
    noanime = "systemctl --user stop asusd-user && animeclr";
    anime = "animeclr && systemctl --user start asusd-user";
    demosplash = "asusctl anime pixel-image -p ~/.config/rog/bad-apple.png";
    nodemo = "tmux kill-session -t sound 2> /dev/null; noanime";
    demo = "nodemo && anime && sleep 0.5 && tmux new -s sound -d 'play ~/Music/bad-apple.mp3 repeat -'";
  };
  nixAliases =
    let
      inherit flakePath;
    in
    {
      iusenixbtw = "fastfetch";
      # n = "home-manager switch --flake ${flakePath}";
      n = "nh home switch ${flakePath}";
      # nn = "nixos-rebuild switch --flake ${flakePath}";
      nn = "nh os switch ${flakePath}";
      # nnn = "nn && n";
      # nd = "nix-collect-garbage -d";
      nd = "nh clean all --keep 5 --keep-since 4d";
      nr = "nixos-rebuild repl --flake ${flakePath}";
      # nr = "nh os repl ${flakePath}";
      ne = "editor ${flakePath}";
      ndiff = "nvd diff ~/.local/state/nix/profiles/home-manager ~/.local/state/nix/profiles/$(command ls -t ~/.local/state/nix/profiles | fzf)";
      nndiff = "nvd diff /nix/var/nix/profiles/system /nix/var/nix/profiles/$(command ls -t /nix/var/nix/profiles/ | fzf)";
      nix-shell = "nix-shell --run fish";
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
    // rogG14Aliases
    // nixAliases;
  fisn'tAliases = {
    "?" = "type";
  };
in
{
  home.sessionVariables = {
    PAGER = "bat";
    LESS = "--mouse";
  };
  xdg.configFile."shell/functions.sh" = {
    source = ../.config/shell/functions.sh;
  };
  # TODO: finer way to do it
  xdg.configFile."shell/wifite.sh" = {
    source = ../.config/shell/wifite.sh;
  };
  xdg.configFile."shell/g14.sh" = {
    source = ../.config/shell/g14.sh;
  };
  xdg.configFile."shell/setup.sh" = {
    source = ../.config/shell/setup.sh;
  };
  programs.zsh = {
    enable = true;
    shellAliases = sharedAliases // fisn'tAliases;
    history = {
      size = 100000;
    };
    autocd = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initExtra = ''
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
      # ctrl + backspace
      bindkey "^H"      backward-kill-word
      # ctrl + delete
      bindkey "^[[3;5~" delete-word
      # alt + backspace
      bindkey "^[^H"    backward-kill-word
      # alt + delete
      bindkey "^[[3;3~" delete-word

      source "$XDG_CONFIG_HOME"/shell/functions.sh
    '';
  };
  programs.bash = {
    enable = true;
    historySize = 100000;
    historyControl = [ "ignoreboth" ];
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
    # config = {
    #   theme = "TwoDark";
    # };
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
  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ../.config/starship.toml);
  };
  xdg.configFile."starship/starship.bash" = {
    source = ../.config/starship/starship.bash;
  };
  programs.yazi = {
    enable = true;
  };
  programs.lazygit.enable = true;
  programs.btop = {
    enable = true;
    settings = {
      proc_tree = true;
    };
  };
}
