# Worst Nix/OS config ever

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

## [mpv](.config/mpv/)

- mpv.conf
  - no-border
  - snap-window
  - save-position-on-quit
  - screenshot-directory is desktop
  - ontop only when playing
  - profiles
    - playlist
      - move window to right down corner
      - resize to 25% of screen width
    - online (http)
      - same as playlist
    - music (mp3)
      - always show window
      - don't save position
  - TODO
    - headers based on link profile
    - additional track settings
      - sub/aud folder search
      - #Audio language priority
      - alang=ru,rus,en,eng,ja,jp,jpn
      - #Subtitle language priority
      - slang=ru,rus,en,eng,ja,jp,jpn
- input.conf
  - patched ru keybinds
  - middle mouse button to pin window on top
  - _/- to cycle video tracks
  - =/+ to cycle window sizes
  - Alt+[0-6] keys to change window size
  - k shuffle playlist
  - Alt+k unshuffle playlist
  - K loop/unloop playlist
  - n show file tags
  - [crop/encode](https://github.com/occivink/mpv-scripts/blob/master/input.conf)
    - crop
      - c for crop
      - Alt+c for soft crop
      - C for toggle crop (remove filter and crop)
      - l blur logo
      - d remove crop filter
      - D remove soft crop
    - encode
      - e for webm no audio
      - E for source
      - Alt+e for mp4 no audio
- [crop/encode scripts](https://github.com/occivink/mpv-scripts)
  - [crop fix](https://github.com/occivink/mpv-scripts/pull/77/files)

## TODO

- [vscode LSP](https://github.com/nix-community/vscode-nix-ide/tree/main?tab=readme-ov-file#lsp-plugin-support)
- [no internet](https://www.reddit.com/r/NixOS/comments/mu7ryg/comment/gv4kmsk/)
  - [LiveCD](https://wiki.nixos.org/wiki/Creating_a_NixOS_live_CD)
- [flake-parts](https://nix-community.github.io/home-manager/index.xhtml#sec-flakes-flake-parts-module)
- [guix environment like](https://github.com/NixOS/nix/issues/8207)
  - [containter](https://wiki.nixos.org/wiki/NixOS_Containers)
  - [firejail](https://github.com/netblue30/firejail)
- [bat extras](https://github.com/eth-p/bat-extras)
- nvim
  - nvimpager
    - enable syntax hightlighting
    - disable all other
    - batman ?
  - init.lua vim types
- [mpv](https://wiki.nixos.org/wiki/MPV#Where_to_get_scripts)
- <https://www.scootersoftware.com/kb/linux_install>
- nix repl get packages to install
- refs
  - <https://github.com/Andrey0189/nixos-config>
  - <https://github.com/hlissner/dotfiles>
  - <https://github.com/MatthewCroughan/nixcfg>
  - <https://mynixos.com/>
- left
  - G14 anime
  - KDE
    - <https://wiki.nixos.org/wiki/KDE#Configuration>
  - root
    - sudo alias
    - passwd
  - <https://wiki.nixos.org/wiki/Dual_Booting_NixOS_and_Windows>
    - <https://wiki.nixos.org/wiki/Secure_Boot>
  - <https://wiki.nixos.org/wiki/ZFS>
    - <https://discourse.nixos.org/t/how-good-is-zfs-on-root-on-nixos/40512>
  - systemd editor path ?
  - [amnezia modprobe secure boot](https://www.reddit.com/r/AmneziaVPN/comments/1e8fwih/amneziawg_on_nixos/)
  -
    - `[ -f "$XDG_CONFIG_HOME/bash/config.bash" ] && source $XDG_CONFIG_HOME/bash/config.bash`
    - `. "$HOME/.cargo/env"`
  - `functuions.sh`
    - setup_font
      - <https://wiki.nixos.org/wiki/Fonts>
    - setup_docker ?
    - root passwd ?
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
  - 25.05
    - awg
    - isd
    - `nh os repl`
    - services.syncthing.tray.command
    - vscode.profiles
    - mesa 25
      - plasma-desktop 6.3
        - cursors?
