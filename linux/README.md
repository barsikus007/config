# [Linux](../README.md)

## [Command Cheat Sheet](./cheatsheet.md)

## [WSL Hints](./wsl.md)

## [ethical hacking](./hax.md)

## [raspberry pi zero w](./devices/rpi-zero.md)

## Archive

### Install Config

> [!WARNING]
> DEPRECATION WARNING!!! I USE NIX NOW

#### Deps

```shell
#? ubuntu
sudo apt install git -y

#? all
chsh -s /bin/bash
```

#### Clone

```shell
cd && git clone https://github.com/barsikus007/config --depth 1 && cd -
```

#### Install/Update

```shell
#? all
cd ~/config/ && git pull && ./linux/install.sh && cd -

setup_ubuntu

#? others
setup_linux
```
