# [Linux](../README.md)

## [Command Cheat Sheet](./cheatsheet.md)

## [WSL Hints](./wsl.md)

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
cd && git clone --depth=1 https://github.com/barsikus007/config && cd -
```

#### Install/Update

```shell
#? all
cd ~/config/ && git pull && ./linux/install.sh && cd -

setup_ubuntu

#? others
setup_linux
```
