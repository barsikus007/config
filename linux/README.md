# [Linux](../README.md)

## [Command Cheat Sheet](./cheatsheet.md)

### [Server](./cheatsheet_server.md)

### [Desktop](./cheatsheet_desktop.md)

## [WSL Hints](./wsl.md)

## [ethical hacking](./hax.md)

## [raspberry pi zero w](./devices/rpi-zero.md)

## Archive

### Install Config

> [!WARNING]
> DEPRECATION WARNING!!! I USE NIX NOW

#### Deps

```sh
#? ubuntu
sudo apt install git -y

#? arch
sudo pacman -S git

#? all
chsh -s /bin/bash
```

#### Clone

```sh
cd && git clone https://github.com/barsikus007/config --depth 1 && cd -
```

#### Install/Update

```sh
#? all
cd ~/config/ && git pull && ./configs/install.sh && cd -

setup_ubuntu

setup_arch

#? others
setup_linux
```
