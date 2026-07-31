# [Linux](../README.md)

## [command cheat sheet](./cheatsheet.md)

## [WSL hints](./wsl.md)

## [Raspberry Pi Zero W](./devices/rpi-zero.md)

## archive

### install config

> [!WARNING]
> DEPRECATION WARNING!!! I USE NIX NOW

#### deps

```shell
#? ubuntu
sudo apt install git -y

#? all
chsh -s /bin/bash
```

#### clone

```shell
cd && git clone --depth=1 https://github.com/barsikus007/config && cd -
```

#### install/update

```shell
#? all
cd ~/config && git pull && ./linux/install.sh && cd -

setup_ubuntu

#? others
setup_linux
```

#### check size

TLDR: before: 162M; after: 440M; time: 4m18s

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
