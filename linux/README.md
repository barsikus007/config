# [Linux](../README.md)

## Install Config

### Deps

- git
  - `sudo apt install git -y`
- `chsh -s /bin/bash`

### Clone

- `cd && git clone https://github.com/barsikus007/config --depth 1 && cd -`

### Install/Update

- `cd ~/config/ && git pull && ./configs/install.sh && cd -`
- TODO `setup_ubuntu`

## [Command Cheat Sheet](cheatsheet.md)

## [WSL Hints](wsl.md)

## [Router Setup](devices/ax3600.md)

## Information

- Default location for wg0 file is user home

## TODO

- py python alias
- config #!/bin/sh -eux
- explain command
- systemctl edit nvim config
- `zpool status -v` alias
- `sudo dnf clean all`
- [test link+](../README.md)
- [test link](/../../)
- [test link](../../../)
- <https://github.com/ivan-hc/AM-Application-Manager>
- <https://unix.stackexchange.com/questions/408413/change-default-editor-to-vim-for-sudo-systemctl-edit-unit-file>
- Control_R as modifier in gnome
- `sudo dnf install file-roller-nautilus`
- shells
  - change shell to fish `usermod -s /usr/bin/fish $USERNAME`
  - show cached state of sudo in prompt (starship)
  - apply config changes `cd ~/config/ && git pull && ./configs/install.sh && cd -` (assume that it installed in home dir (env variable `$CONFIG_LOCATION?`))
  - todo fix order
    - [ -f "$XDG_CONFIG_HOME/bash/config.bash" ] && source $XDG_CONFIG_HOME/bash/config.bash fix bashrc
  - adapt config.bash file to other shells
  - `$XDG_CONFIG_HOME/shell/aliases.sh` for root user
  - alias resolve package manager for u
  - ic command to update config
  - correct link things like bat to cat
- <https://docs.docker.com/desktop/install/linux-install/#generic-installation-steps>
- fedora
  - <https://flatpak.org/setup/Fedora>
  - <https://www.linuxcapable.com/install-telegram-on-fedora-linux/>
- flatpak apps
  - com.parsecgaming.parsec
  - org.telegram.desktop
  - ? org.telegram.desktop.webview
  - com.raggesilver.BlackBox
    - <https://github.com/dr3mro/blackbox-installer>
- FireFox moment
  - [Firefox PWA](https://addons.mozilla.org/en-US/firefox/addon/pwas-for-firefox/)
  - tree style tab

## GNOME

- TODO gnome tweaks
- TODO [adwaita for GTK3](https://github.com/lassekongo83/adw-gtk3)
- [GNOME Shell Extensions](https://extensions.gnome.org/local)
  - default
    - [for telegram and docker desktop badges](https://extensions.gnome.org/extension/615/appindicator-support/)
    - [emoji](https://extensions.gnome.org/extension/1162/emoji-selector/)
    - [fix desktop](https://extensions.gnome.org/extension/2087/desktop-icons-ng-ding/)
    - [clipboard history](https://extensions.gnome.org/extension/5278/pano/)
      - change `Global Shortcut` from `Shift+Super+V` to `Super+V`
      - disable sound
    - [Gnome Tweaks 2.0](https://extensions.gnome.org/extension/3843/just-perfection/)
      - Behavior -> Window Demands Attention Focus -> On
  - laptop
    - [windows-like gestures](https://extensions.gnome.org/extension/4245/gesture-improvements/)
    - [Profile badge indicator](https://extensions.gnome.org/extension/5335/power-profile-indicator/)
    - [GPU in power menu](https://extensions.gnome.org/extension/5344/supergfxctl-gex/)
