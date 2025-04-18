# Nix/OS

## Installation

```bash
cd
git clone https://github.com/barsikus007/config
cp config/nix/ ~/
cd ~/nix/
sudo nixos-rebuild switch --flake .
home-manager switch --flake .
```

## Nix itself

### [WSL distro](https://nix-community.github.io/NixOS-WSL/)

### [Nix install](https://zero-to-nix.com/start/install/) speedrun on existing system

- `curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install`
  - enable systemd if wsl

## TODO

- [vscode LSP](https://github.com/nix-community/vscode-nix-ide/tree/main?tab=readme-ov-file#lsp-plugin-support)
- way to compile nixos to files for non nix distros
- [no internet](https://www.reddit.com/r/NixOS/comments/mu7ryg/comment/gv4kmsk/)
  - [LiveCD](https://wiki.nixos.org/wiki/Creating_a_NixOS_live_CD)
- [flake-parts](https://nix-community.github.io/home-manager/index.xhtml#sec-flakes-flake-parts-module)
- [guix environment like](https://github.com/NixOS/nix/issues/8207)
  - [containter](https://wiki.nixos.org/wiki/NixOS_Containers)
  - [firejail](https://github.com/netblue30/firejail)
- [bat extras](https://github.com/eth-p/bat-extras)
- nvim
  - <https://github.com/BirdeeHub/nixCats-nvim>
  - <https://github.com/nix-community/nixvim>
  - <https://github.com/NotAShelf/nvf>
    - show hidden
  - nvimpager
  -
    - go to definition
    - indent
- refs
  - <https://github.com/Andrey0189/nixos-config>
  - <https://github.com/hlissner/dotfiles>
  - <https://github.com/MatthewCroughan/nixcfg>
- left
  - KDE
    - <https://wiki.nixos.org/wiki/KDE#Configuration>
  - root
    - sudo alias
    - passwd
  - systemd editor path ?
  -
    - `[ -f "$XDG_CONFIG_HOME/bash/config.bash" ] && source $XDG_CONFIG_HOME/bash/config.bash`
    - `. "$HOME/.cargo/env"`
  - functuions.sh
    - setup_font
      - <https://wiki.nixos.org/wiki/Fonts>
    - setup_docker ?
    - root passwd ?
    - starship ?
    -
      - mkcd() { (mkdir -p "$@" && cd "$@" || exit;) }
      - ssht() { (ssh "$@" -t "tmux new -As0 || bash || sh") }
      - dcsh() { docker compose exec -it "$1" sh -c 'bash || sh'; }
  - programs.bat.extraPackages
    - batdiff?
    - batman ?
  - `nix-store --query --graph result`
  - `https://wiki.nixos.org/wiki/Git#Using_your_public_SSH_key_as_a_signing_key`
  - <https://github.com/jesseduffield/lazydocker/blob/master/docs/Config.md>
  -
    - mpv
    - mkcd
    - ssht
    - dcsh
    - cu
    - pipi
    - ?
      - pyvcr
      - pyv
  - python
    - direnv
    - uv2nix
