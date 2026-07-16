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
cd ~/config && git pull && ./linux/install.sh && cd -

setup_ubuntu

#? others
setup_linux
```

#### Check Size

TLDR: before: 162M; after: 424M; diff: 262M

```shell
docker run --rm ubuntu:latest bash -c '
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq >/dev/null && apt-get install -y -qq git sudo >/dev/null
mkdir --parents /etc/apt/sources.list.d && touch /etc/apt/sources.list.d/nala-sources.list
echo "=== BEFORE ==="; du -shx /
cd && git clone --depth=1 -q https://github.com/barsikus007/config && cd -
cd ~/config && ./linux/install.sh && cd -
printf "y\n" | bash -ic setup_ubuntu
echo "=== AFTER  ==="; du -shx /
'
```
