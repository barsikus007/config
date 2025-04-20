{ config, pkgs, ... }:

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
    # TODO: sshe = "editor ~/.ssh/config";
    nv = "editor $(fzf)";
    nvf = "editor $(find \"/\" | fzf)";
    nvs = "editor $(rg -n . | fzf | awk -F: '{print \"+\"$2,$1}')";
    "1ip" = "wget -qO - icanhazip.com";
    "2ip" = "curl 2ip.ru";
    # https://www.cyberciti.biz/faq/unix-linux-check-if-port-is-in-use-command/
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
  # TODO: non ported
  otherAliases = {
    gdu = "gdu -I ^/mnt";
    zps = "zpool status -v";
    wgu = "wg-quick up ~/wg0.conf";
    wgd = "wg-quick down ~/wg0.conf";
    sex = "explorer.exe .";
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
  # TODO detect if ROG G14
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
      flakePath = "~/config/nix";
    in
    {
      iusenixbtw = "fastfetch";
      # n = "home-manager switch --flake ${flakePath}";
      n = "nh home switch ${flakePath}";
      # nn = "nixos-rebuild switch --flake ${flakePath}";
      nn = "nh os switch ${flakePath}";
      nnn = "nn && n";
      # nd = "nix-collect-garbage -d";
      nd = "nh clean all";
      ne = "editor ${flakePath}";
    };
  sharedAliases =
    baseAliases
    // dockerAliases
    // pythonAliases
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
  programs.zsh = {
    enable = true;
    shellAliases = sharedAliases // fisn'tAliases;
    history = {
      size = 100000;
    };
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initExtra = ''
      bindkey "^[[1;5D" backward-word
      bindkey "^[[1;5C" forward-word
      bindkey "^[[5~"   beginning-of-history
      bindkey "^[[6~"   end-of-history
      # bindkey -e
      # bindkey "^[[H"    beginning-of-line
      # bindkey "^[[F"    end-of-line
      # bindkey "^[[3~"   delete-char
      # source $(./functions.sh)
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
    config = {
      theme = "TwoDark";
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
  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ../.config/starship.toml);
  };
  xdg.configFile."starship/starship.bash" = {
    source = ../.config/starship/starship.bash;
  };
}
