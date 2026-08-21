# [worst Nix/OS config ever](../README.md)

modular Nix configurations for desktops, servers, virtual machines and mobile devices

## [packages](./packages/README.md)

## [command cheat sheet](./cheatsheet.md)

## installation

```shell
cd
git clone --depth=1 https://github.com/barsikus007/config
# cp config/nix/ ~/ && cd nix/
cd ~/config/nix/
sed --in-place 's/ogurez/YOUR_USERNAME/' flake.nix
sudo nixos-rebuild switch --flake .

#? enable pre-commit
cd ..
prek install
```

### Asus ROG G14 2020-2021 [fingerprint scanner](https://github.com/knauth/goodix-521d-explanation)

<https://github.com/goodix-fp-linux-dev/goodix-fp-dump/blob/master/README.md>

~~too lazy to write this on nix~~

`sudo $(nix build 'github:barsikus007/config?dir=nix#libs.goodix-patch-521d' --print-out-paths)/bin/run_521d`

(`OSError: [Errno 30] Read-only file system: 'clear-0.pgm'` output is <ins>__normal__</ins>)

### [NixOS Android](./hosts/android/README.md)

### [WSL distro](https://nix-community.github.io/NixOS-WSL/)

`sudo nixos-rebuild switch --flake .#NixOS-WSL`

### plain [nix installer](https://github.com/NixOS/nix-installer) on existing system

- TLDR
  - `curl --proto '=https' --tlsv1.2 --silent --show-error --fail --location https://artifacts.nixos.org/nix-installer | sh -s -- install --enable-flakes`
  - [offline](https://github.com/NixOS/nix-installer/releases/latest/download/nix-installer-x86_64-linux)
- [uninstaller](https://github.com/NixOS/nix-installer#uninstalling)
  - `/nix/nix-installer uninstall`

## config reference

### [vscode](.config/Code/User/)

- extensions manager script: `./nix/.config/Code/User/extensions-manager.sh`
  - shows diff between extensions in `code` and defined in `extensions.nix`
- TODO
  - export configs
    - layout
      - `code ~/.config/Code/User/globalStorage/state.vscdb`
    - profiles
      - create profiles with given subset of
        - extensions (based on tags)
        - settings (based on regions)
  - python
    - pycharm like run file
      - without interactive shell loading
    - "python.analysis.autoImportCompletions": true
      - could stop work for no reason
    - debug inside python container
    - disable parenthesis when apply auto-import
    - color logs
      - in debug console ?
      - not python specific ?
  - new things
    - compound logs
    - <https://code.visualstudio.com/docs/copilot/copilot-customization#_reusable-prompt-files-experimental>
    - <https://code.visualstudio.com/docs/copilot/copilot-customization>
    - <https://code.visualstudio.com/updates/v1_98#_task-rerun-action>
    - <https://github.com/microsoft/vscode/pull/248747>

### [mpv](.config/mpv/)

- uosc skin
  - with thumbfast
- `mpv.conf`
  - `no-border`
  - `snap-window`
  - `save-position-on-quit`
  - `screenshot-directory` is `desktop/`
  - screenshot filename is more declare
  - sub font will be searched in `fonts/`
  - sub/aud language priority
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
- `input.conf`
  - patched ru keybinds
  - `F1` to show keybinds visually
  - `middle-mouse-button` to pin window on top
  - `_/-` to cycle video tracks
  - `=/+` to cycle window sizes
  - `Alt+[0-6]` keys to change window size
  - `k` shuffle playlist
  - `Alt+k` unshuffle playlist
  - `K` loop/unloop playlist
  - `n` show file tags
  - [crop/encode](https://github.com/occivink/mpv-scripts/blob/master/input.conf)
    - crop
      - `c` for crop
      - `Alt+c` for soft crop
      - `C` for toggle crop (remove filter and crop)
      - `l` blur section
      - `d` remove crop filter
      - `D` remove soft crop
    - encode
      - `e` for webm no audio
      - `E` for source
      - `Alt+e` for mp4 no audio
- [crop/encode scripts](https://github.com/occivink/mpv-scripts)
  - [crop fix](https://github.com/occivink/mpv-scripts/pull/77/files)

## other

- Steam
  - Top left steam logo > Settings > Compatibility
    - Enable steam play for all titles
    - Default compatibility tool: GE-Proton
  - [NTFS library fix](https://github.com/ValveSoftware/Proton/wiki/Using-a-NTFS-disk-with-Linux-and-Windows#preventing-ntfs-read-errors)
  - `nvidia-offload gamemoderun mangohud %command%`
- Throne (formerly known as nekoray/nekobox)
  - Routing -> Routing settings -> DNS -> Direct DNS: `8.8.8.8`
