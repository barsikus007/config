# [Worst Nix/OS config ever](../README.md)

Goal is to provide modular close to windows-godlike desktop experience

## [Command Cheat Sheet](cheatsheet.md)

## Installation

```bash
cd
git clone https://github.com/barsikus007/config
# cp config/nix/ ~/ && cd nix/
cd ~/config/nix/
sed -i 's/ogurez/YOUR_USERNAME/' flake.nix
sudo nixos-rebuild switch --flake .
home-manager switch --flake .
```

Set user password and TODO other steps from [NixOS installation manual](https://nixos.org/manual/nixos/stable/#ch-installation)

### G14

#### [Fingerprint scanner](https://github.com/knauth/goodix-521d-explanation)

Too lazy to write this on nix

<https://github.com/goodix-fp-linux-dev/goodix-fp-dump/blob/master/README.md>

1. `git clone --recurse-submodules https://github.com/goodix-fp-linux-dev/goodix-fp-dump.git && cd goodix-fp-dump`
2. Create `shell.nix` with content below
3. Enter nix shell `nix-shell`
4. `sudo python3 run_521d.py`
   1. Catch "Invalid OTP" and cry ;-;
   2. I kidding, comment that checking at L133:L134

`shell.nix`

```nix
{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    openssl
    (python3.withPackages (
      ps: with ps; [
        pyusb
        crcmod
        python-periphery
        spidev
        pycryptodome
        crccheck
      ]
    ))
  ];
}
```

## Nix itself

### [WSL distro](https://nix-community.github.io/NixOS-WSL/)

### [Nix install](https://zero-to-nix.com/start/install/) speedrun on existing system

- `curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install`
  - enable systemd if wsl

## Config reference

### [vscode](.config/Code/User/)

- TODO
  - export configs
    - layout
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
  - Top left steam logo > Settings > Compatibility > Enable steam play for all titles
  - [NTFS library fix](https://github.com/ValveSoftware/Proton/wiki/Using-a-NTFS-disk-with-Linux-and-Windows#preventing-ntfs-read-errors)
  - `nvidia-offload gamemoderun mangohud %command%`

## TODO

- [flake-parts](https://nix-community.github.io/home-manager/index.xhtml#sec-flakes-flake-parts-module)
- parse nix files for pkgs (or do it via nix script)
- better way to work with functions in shell.nix
- GUI
  - move badapple gif and mp3 outsude of git (or genereate them idk)
  - obs
    - quick replay (import scenes)
      - battery/ac based quality

### Shell

#### New software

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

#### Alias

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

#### Other

- [guix environment like](https://github.com/NixOS/nix/issues/8207)
  - [containter](https://wiki.nixos.org/wiki/NixOS_Containers)
    - [nixpak](https://github.com/nixpak/nixpak)
  - [firejail](https://github.com/netblue30/firejail)
- bat
  - [zsh '--help' alias](https://github.com/sharkdp/bat#highlighting---help-messages)
    - [explain command](https://github.com/learnbyexample/command_help)
- nvim
  - nvimpager
    - enable syntax hightlighting
    - disable all other
    - batman ?
  - init.lua vim types
- .editorconfig conf
  - make it global ?

### 25.05

- `nh os repl`
- stylix
  - cursor fix
  - fonts fix
