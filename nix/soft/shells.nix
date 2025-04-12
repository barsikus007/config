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
    nvs = "nvim +'Telescope live_grep' hidden=true'";
  };
  nixAliases =
    let
      flakePath = "~/nix";
    in
    {
      iusenixbtw = "fastfetch";
      n = "home-manager switch --flake ${flakePath};";
      nn = "sudo nixos-rebuild switch --flake ${flakePath}";
      nnn = "nn & nn";
      nd = "nix-collect-garbage -d";
      ne = "editor ${flakePath}";
    };
  sharedAliases =
    baseAliases
    // dockerAliases
    // pythonAliases
    // otherAliases
    // ezaAliases
    // nvimAliases
    // nixAliases;
  fisn'tAliases = {
    "?" = "type";
  };
in
{
  programs.bash = {
    enable = true;
    historySize = 100000;
    historyControl = "ignoreboth";
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
      theme = "TwoDark";
    };
  };
}
