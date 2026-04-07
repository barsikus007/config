{
  lib,
  pkgs,
  flakePath,
}:
let
  mkVpnAliases = args: {
    "${args.prefix}u" = "sudo systemctl start ${args.service}";
    "${args.prefix}s" = "systemctl status ${args.service}";
    "${args.prefix}d" = "sudo systemctl stop ${args.service}";
    "${args.prefix}r" = "sudo systemctl restart ${args.service}";
    "${args.prefix}w" = args.watchCommand;
  };
  mKWgAliases =
    args:
    mkVpnAliases {
      prefix = args.wgExec;
      service = "wg-quick-${args.wgIface}";
      watchCommand = "sudo watch -c 'WG_COLOR_MODE=always ${args.wgExec} show'";
    };
in
rec {
  baseAliases = {
    #? https://askubuntu.com/a/22043
    #? https://superuser.com/a/1655578
    sudo = "sudo env PATH=$PATH ";
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
    nvf = ''editor $(find "/" | fzf)'';
    nvs = "editor $(rg -n . | fzf | awk -F: '{print \"+\"$2,$1}')";
    cu = "cd ${flakePath} && git pull && cd -";
    diff = "diff --color";
    #? https://www.cyberciti.biz/faq/unix-linux-check-if-port-is-in-use-command/
    open-ports = "sudo lsof -i -P -n | grep LISTEN";
  };
  networkTestAliases = {
    "1ip" = "wget -qO - icanhazip.com";
    "2ip" = "curl 2ip.ru";
    "3ip" = "curl -so- ipinfo.io | jq";
    "4ip" = "curl -so- wtfismyip.com/json | jq";
    speedtest = "curl https://speedtest.selectel.ru/100MB --output /dev/null";
    speedtest-as-youtube = "curl --insecure --connect-to ::speedtest.selectel.ru https://www.youtube.com/100MB --output /dev/null";
  };
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
  };
  # TODO: non ported
  pythonAliases = {
    pipi = "uv pip install -r requirements.txt || uv pip install -r pyproject.toml";
    pyvcr = "uv venv --allow-existing && source .venv/bin/activate && pipi";
    pyv = "source .venv/bin/activate || pyvcr";
    pyt = "ptpython";
    pyta = "pyt --asyncio";
  };
  npxAliases =
    let
      npxExec = "bunx";
    in
    {
      claude-preview = "${npxExec} @anthropic-ai/claude-code@next";
      gemini-preview = "${npxExec} @google/gemini-cli@preview";
    };
  wgAliases = mKWgAliases rec {
    wgExec = "wg";
    wgIface = "${wgExec}0";
  };
  awgAliases = mKWgAliases rec {
    wgExec = "awg";
    wgIface = "${wgExec}0";
  };
  xrayAliases =
    let
      service = "dae";
    in
    mkVpnAliases {
      inherit service;
      prefix = "xr";
      watchCommand = "journalctl --follow --unit=${service}";
    };
  otherAliases = {
    st = "systemctl-tui";
    sst = "sudo systemctl-tui";
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
    nv = ''nvim +"lua vim.schedule(function() require('telescope.builtin').oldfiles() end)"'';
    nvf = ''nvim +"lua vim.schedule(function() require('telescope.builtin').find_files({hidden=true}) end)"'';
    nvg = ''nvim +"lua vim.schedule(function() require('telescope.builtin').live_grep({hidden=true}) end)"'';
  };
  journalCtlAliases = {
    jctl = "journalctl";
    jctlb = "jctl --boot=0";
    jctld = "jctlb --dmesg";
    jctlf = "jctl --follow";
  };
  nixAliases = {
    iusenixbtw = "fastfetch";
    nu = "nix flake update --flake ${flakePath}";
    nuu = "nix flake update nixpkgs --override-input nixpkgs nixpkgs/$(nixos-version --hash)";
    n = "nh home switch ${flakePath}";
    nn = "nh os switch ${flakePath} --keep-going";
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
    // networkTestAliases
    // dockerAliases
    // pythonAliases
    // npxAliases
    // wgAliases
    // awgAliases
    // xrayAliases
    // otherAliases
    // ezaAliases
    // nvimAliases
    // journalCtlAliases;
  zshAliases = {
    #? https://bbs.archlinux.org/viewtopic.php?id=132830
    sudo = "nocorrect sudo env PATH=$PATH ";
    "?" = "type_colored_and_nix_truncate";
    "??" = "type_colored";
    history-cat = "nvim -R +'set filetype=bash' ~/.config/zsh/.zsh_history";
    history-edit = "code --reuse-window ~/.config/zsh/.zsh_history";
  };
}
