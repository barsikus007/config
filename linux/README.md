# [Linux](../README.md)

## [Command Cheat Sheet](cheatsheet.md)

### [Server](cheatsheet_server.md)

## [WSL Hints](wsl.md)

## [Router Setup](devices/ax3600.md)

## Archive

### Install Config

> [!WARNING]
> DEPRECATION WARNING!!! I USE NIX NOW

#### Deps

- `sudo apt install git -y`
- `chsh -s /bin/bash`

#### Clone

- `cd && git clone https://github.com/barsikus007/config --depth 1 && cd -`

#### Install/Update

- `cd ~/config/ && git pull && ./configs/install.sh && cd -`
- TODO `setup_ubuntu`
