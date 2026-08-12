# [Linux](../README.md)

## [command cheat sheet](./cheatsheet.md)

## installation

### deps

```shell
#? ubuntu
sudo apt install git --assume-yes

#? all
chsh --shell /bin/bash
```

### clone

```shell
cd && git clone --depth=1 https://github.com/barsikus007/config && cd -
```

### install/update

```shell
#? all
cd ~/config && git pull && ./linux/install.sh && cd -

setup_ubuntu

#? others
setup_linux
```

### check size

TLDR: before: 162M; after: 440M; time: 4m18s

```shell
docker run --rm ubuntu:latest bash -c '
export DEBIAN_FRONTEND=noninteractive
apt-get update --quiet --quiet >/dev/null && apt-get install --assume-yes --quiet --quiet git sudo >/dev/null
mkdir --parents /etc/apt/sources.list.d && touch /etc/apt/sources.list.d/nala-sources.list
echo "=== BEFORE ==="; du --summarize --human-readable --one-file-system /
cd && git clone --depth=1 --quiet https://github.com/barsikus007/config && cd -
cd ~/config && ./linux/install.sh && cd -
printf "y\n" | bash -ic setup_ubuntu
echo "=== AFTER  ==="; du --summarize --human-readable --one-file-system /
'
```
