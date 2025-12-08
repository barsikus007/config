# [Worst Nix/OS config ever](../README.md)

Goal is to provide modular close to windows-godlike desktop experience

## [Command cheatsheet](./cheatsheet.md)

## Installation

```shell
cd
git clone https://github.com/barsikus007/config
# cp config/nix/ ~/ && cd nix/
cd ~/config/nix/
sed -i 's/ogurez/YOUR_USERNAME/' flake.nix
sudo nixos-rebuild switch --flake .
home-manager switch --flake .
```

Set user password and TODO other steps from [NixOS installation manual](https://nixos.org/manual/nixos/stable/#ch-installation)

### nix-on-droid specific

1. in `~/.config/nix-on-droid/flake.nix`
   1. set `nixpkgs` input to `nixpkgs-unstable` branch
2. in `~/.config/nix-on-droid/nix-on-droid.nix`
   1. add `pipe-operators` to `experimental-features`
   2. add `git` to `environment.packages`
3. `nix-on-droid switch --flake ~/.config/nix-on-droid`
4. `cd && git clone https://github.com/barsikus007/config && cd -`
5. `nix-on-droid switch --flake ~/config/nix`

### Asus ROG G14 2020-2021 specific

#### [Fingerprint scanner](https://github.com/knauth/goodix-521d-explanation)

<https://github.com/goodix-fp-linux-dev/goodix-fp-dump/blob/master/README.md>

~~Too lazy to write this on nix~~

```shell
sudo $(nix build 'github:barsikus007/config?dir=nix#goodix-patch-521d' --print-out-paths)/bin/run_521d
sudo $(nix build ~/config/nix#goodix-patch-521d --print-out-paths)/bin/run_521d
```

### nix itself

#### [WSL distro](https://nix-community.github.io/NixOS-WSL/)

#### [Nix install](https://zero-to-nix.com/start/install/) speedrun on existing system

- TLDR
  - `curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install`
    - enable systemd if wsl
    - alt installer `curl --proto '=https' --tlsv1.2 -sSf -L https://artifacts.nixos.org/experimental-installer | sh -s -- install`
  - [offline install](https://github.com/DeterminateSystems/nix-installer/releases/latest/download/nix-installer-x86_64-linux)

#### [Nix uninstall](https://zero-to-nix.com/start/uninstall/)

- TLDR
  - `/nix/nix-installer uninstall`

## Config reference

### [vscode](.config/Code/User/)

- TODO
  - export configs
    - layout
      - `code ~/.config/Code/User/globalStorage/state.vscdb`
    - extensions
      - remove/sort
        - use profiles
          - make own profiles system with minimal overhead
            - nixos?
    - profiles
  - python
    - -File activate envs
    - pycharm like run file
    - "python.analysis.autoImportCompletions": true
      - could stop work for no reason
    - debug inside python container
    - disable parenthesis when apply auto-import
    - color logs
      - in debug console ?
      - not python specific ?
  - new things
    - compound logs check
    - cssho.vscode-svgviewer is needed?
    - jock.svg is needed?
    - <https://code.visualstudio.com/docs/copilot/copilot-customization#_reusable-prompt-files-experimental>
    - <https://code.visualstudio.com/docs/copilot/copilot-customization>
    - <https://code.visualstudio.com/updates/v1_98#_task-rerun-action>
      - VERY new things
        - <https://github.com/microsoft/vscode/pull/248747>
  - [comment to specify syntax highlight language (inline syntax highlight)](https://nixtips.ru/home-manager/introduction#пример-конфигурации-абстрактного-пакета)
  - stage selected button
    - also buttons to switch file generations disappearing
  - <https://github.com/kahole/edamagit>

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

## Imperative

### GUI

- Steam
  - Top left steam logo > Settings > Compatibility
    - Enable steam play for all titles
    - Default compatibility tool: GE-Proton
  - [NTFS library fix](https://github.com/ValveSoftware/Proton/wiki/Using-a-NTFS-disk-with-Linux-and-Windows#preventing-ntfs-read-errors)
  - `nvidia-offload gamemoderun mangohud %command%`
- Throne (formerly known as nekoray/nekobox)
  - Routing -> Routing settings -> DNS -> Direct DNS: `8.8.8.8`

## TODO

- Syncthing Tray/service setup info (isn't declarative)
- [flake-parts](https://nix-community.github.io/home-manager/index.xhtml#sec-flakes-flake-parts-module)
- parse nix files for pkgs (or do it via nix script)
- better way to work with functions in shell.nix
- GUI
  - obs
    - quick replay (import scenes)
      - battery/ac based quality
- nix-on-droid
  - `nix-shell -p <smth>`
    - needs for channel?
  - [sudo](https://github.com/nix-community/nix-on-droid/issues/252)
    - not worth it, use [NixOS-AVF](https://github.com/nix-community/nixos-avf)
- [OpenWrt Image](./packages/openwrt/xiaomi_ax3600.nix)
  - [uci](./packages/openwrt/dewclaw.nix)
    - make it)
    - [disable IPV6](https://3os.org/infrastructure/openwrt/disable-ipv6/)

### shell

#### new software

- zsh or fish (or bash lol)
- [dive](https://github.com/wagoodman/dive)
- [Mosh: the mobile shell](https://mosh.org/)
- <https://github.com/pojntfx/octarchive>
- [yassinebridi/serpl: A simple terminal UI for search and replace, ala VS Code.](https://github.com/yassinebridi/serpl)
  - <https://ast-grep.github.io/>
- test.nix
  - lshw-gui
  - new add security scanners
    - nikto
    - ffuf
    - seclists
    - frida-tools
    - wifite2
    - nmap alts
      - rustscan
      - zmap

#### alias

- 'sudo '
- fzf
  - !autocompletion
  - wgu selector
    - best location for config files
      - agenix secrets?
  - [docker compose](https://www.reddit.com/r/docker/comments/vovo2b/dockerfzf_exec_bash_if_found_otherwise_sh/)
  - fzc alias=fzf ~/config
- grep config folder for cheatsheet
- code=co
- clear=cl
- dcu not pull
- dcup prod
- wsl `find / -not -path '/mnt/*'`
- `find / -not -path '/mnt/*' -name python -not -path '/home/*'`
- git config core.editor=code --wait --new-window
- nv show .files
- nvf current dir or sudo or ignore /proc etc
- llt ls tree
  - or lll
- proto outdated --update

#### other

- [guix environment like](https://github.com/NixOS/nix/issues/8207)
  - [containter](https://wiki.nixos.org/wiki/NixOS_Containers)
    - [nixpak](https://github.com/nixpak/nixpak)
  - [firejail](https://github.com/netblue30/firejail)
- bat
  - [zsh '--help' alias](https://github.com/sharkdp/bat#highlighting---help-messages)
    - [explain command](https://github.com/learnbyexample/command_help)
- nvim
  - init.lua vim types
- stylix
