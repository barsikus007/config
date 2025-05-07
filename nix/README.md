# [Worst Nix/OS config ever](../README.md)

Goal is to provide modular close to windows-godlike desktop experience

## Installation

```bash
cd
git clone https://github.com/barsikus007/config
# cp config/nix/ ~/ && cd nix/
cd ~/config/nix/
sudo nixos-rebuild switch --flake .
home-manager switch --flake .
```

Set user password and TODO other steps from [NixOS installation manual](https://nixos.org/manual/nixos/stable/#ch-installation)

## Nix itself

### [WSL distro](https://nix-community.github.io/NixOS-WSL/)

### [Nix install](https://zero-to-nix.com/start/install/) speedrun on existing system

- `curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install`
  - enable systemd if wsl

## Config reference

### [mpv](.config/mpv/)

- uosc skin
  - with thumbfast
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

- [no internet](https://www.reddit.com/r/NixOS/comments/mu7ryg/comment/gv4kmsk/)
  - [LiveCD](https://wiki.nixos.org/wiki/Creating_a_NixOS_live_CD)
- [flake-parts](https://nix-community.github.io/home-manager/index.xhtml#sec-flakes-flake-parts-module)
- [guix environment like](https://github.com/NixOS/nix/issues/8207)
  - [containter](https://wiki.nixos.org/wiki/NixOS_Containers)
  - [firejail](https://github.com/netblue30/firejail)
- [bat extras](https://github.com/eth-p/bat-extras)
  - programs.bat.extraPackages
    - batdiff?
    - batman ?
- nvim
  - nvimpager
    - enable syntax hightlighting
    - disable all other
    - batman ?
  - init.lua vim types
- parse nix files for pkgs (or do it via nix script)
- better way to work with functions
- alias
  - 'sudo '
  - pipi
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
  - stylix
    - nvf
    - cursor fix
  - mesa 25
    - plasma-desktop 6.3
      - cursors?
