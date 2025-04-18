# [Linux](../README.md)

## [Command Cheat Sheet](cheatsheet.md)

## [WSL Hints](wsl.md)

## [Router Setup](devices/ax3600.md)

## Information

- Default location for wg0 file is user home
  - TODO find fzf chooser for that
  - TODO find proper location for that

## TODO

- shells(.nix)
  - py python alias
  - explain command
    - <https://github.com/learnbyexample/command_help>
  - starship
    - show cached state of sudo in prompt
- FireFox moment
  - [Firefox PWA](https://addons.mozilla.org/en-US/firefox/addon/pwas-for-firefox/)
  - tree style tab
    - Sideberry?

## Archive

### Install Config

> [!WARNING]
> DEPRECATION WARNING!!! I USE NIX NOW

#### Deps

- git
  - `sudo apt install git -y`
- `chsh -s /bin/bash`

#### Clone

- `cd && git clone https://github.com/barsikus007/config --depth 1 && cd -`

#### Install/Update

- `cd ~/config/ && git pull && ./configs/install.sh && cd -`
- TODO `setup_ubuntu`

### GNOME 46/47 workarounds (Fedora targeted)

- TODO Control_R as modifier in gnome
- file-roller-nautilus
  - `sudo dnf install file-roller-nautilus`
- [GNOME moment fix](https://dausruddin.com/how-to-update-gnome-extension-properly-get-rid-of-error/)
  - wtf, no way to restart under wayland...
- [Extension Manager](https://github.com/mjakeman/extension-manager)
- TODO gnome tweaks
- TODO [adwaita for GTK3](https://github.com/lassekongo83/adw-gtk3)
- [GNOME Shell Extensions](https://extensions.gnome.org/local)
  - default
    - [for telegram and docker desktop badges](https://extensions.gnome.org/extension/615/appindicator-support/)
    - [emoji](https://extensions.gnome.org/extension/6242/emoji-copy/)
    - [fix desktop](https://extensions.gnome.org/extension/2087/desktop-icons-ng-ding/)
    - [clipboard history](https://extensions.gnome.org/extension/5278/pano/)
      - install [v23](https://github.com/oae/gnome-shell-pano/releases) for GNOME 46/47
        - unzip to `~/.local/share/gnome-shell/extensions`
        - or `gnome-extensions install -f  pano@elhan.io.zip`
      - change `Global Shortcut` from `Shift+Super+V` to `Super+V`
      - disable sound
    - [Gnome Tweaks 2.0](https://extensions.gnome.org/extension/3843/just-perfection/)
      - Behavior -> Window Demands Attention Focus -> On
  - laptop
    - [windows-like gestures](https://extensions.gnome.org/extension/4245/gesture-improvements/)
      - [GNOME moment](https://github.com/sidevesh/gnome-gesture-improvements--transpiled)
    - [Profile badge indicator](https://extensions.gnome.org/extension/5335/power-profile-indicator/)
    - [GPU in power menu](https://extensions.gnome.org/extension/5344/supergfxctl-gex/)
      - [GNOME moment](https://extensions.gnome.org/extension/7018/gpu-supergfxctl-switch/)
