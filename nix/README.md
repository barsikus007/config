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
- nvim
  - <https://github.com/BirdeeHub/nixCats-nvim>
  - <https://github.com/nix-community/nixvim>
  - <https://github.com/NotAShelf/nvf>
- refs
  - <https://github.com/Andrey0189/nixos-config>
  - <https://github.com/hlissner/dotfiles>
  - <https://github.com/MatthewCroughan/nixcfg>
