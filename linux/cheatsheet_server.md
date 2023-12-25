# [cheatsheet for server](./)

## set new password for root

### arch

```bash
# change root user passwd
sudo passwd root
sudo passwd arch

# create sudo user
export username="ogurez"
sudo useradd -mG wheel $username
sudo passwd $username

# pacman errors workaround
# https://wiki.archlinux.org/title/Mirrors
# sudo pacman-key --init
# sudo pacman-key --populate archlinux
# sudo pacman-key --refresh-keys
# sudo pacman -S archlinux-keyring; sudo pacman -Su

sudo pacman -Suy neovim
EDITOR=nvim sudo visudo
# uncomment wheel lines
```

### ubuntu

```bash
# change root user passwd
sudo passwd root

# create sudo user
export username="ogurez"
adduser $username

usermod -aG sudo $username
passwd $username

su $username
```

## SSH

### generate ssh-key

```bash
rsa_file=filename
ssh-keygen -t rsa -f $rsa_file -P ""
ssh-copy-id -i $rsa_file.pub fox@foxxed.ru
```

### config sshd_config for security

- Port 2222
- PermitRootLogin no
- PasswordAuthentication no
- ChallengeResponseAuthentication no
- KbdInteractiveAuthentication no

``` bash
sshd_file=/etc/ssh/sshd_config
cp $sshd_file ~
sudo sed -i 's/^#Port/Port/' $sshd_file
sudo sed -i 's/^Port 22$/Port 2222/' $sshd_file
for param in {PermitRootLogin,PasswordAuthentication,ChallengeResponseAuthentication,KbdInteractiveAuthentication}; do sudo sed -i "s/^#$param/$param/" $sshd_file && sudo sed -i "s/^$param yes$/$param no/" $sshd_file; done
sudo systemctl reload sshd
```

## UTF-8

```bash
locale
locale -a
# if not C.UTF-8 exists
sudo apt install locales
sudo locale-gen C.UTF-8 en_US.UTF-8
sudo localectl set-locale C.UTF-8
# TODO or update-locale?
# set ru time https://stackoverflow.com/a/30480596/15844518
# sudo locale-gen ru_RU.UTF-8 && sudo localectl set-locale LC_TIME=ru_RU.UTF-8
```

## ZFS

### Install

```bash
sudo apt install zfsutils-linux -y
# sudo apt install zfs-dkms -y
sudo reboot

sudo /sbin/modprobe zfs
```

### Zpool setup

```bash
# check if -O utf8only=on is needed
sudo zpool create -O normalization=formD -O compression=lz4 tank raidz sda sdb sdc sdd

sudo zfs create tank/apps
sudo zfs create tank/storage
sudo zfs create tank/backup

sudo zfs create tank/git?lab
# TODO idk if it's needed
sudo chown -R $USER:$USER /tank/storage/
```

### Add auto snapshot package

`sudo apt install zfs-auto-snapshot -y`

### Enable scrub timer

`sudo systemctl enable zfs-scrub-weekly@tank.timer`

#### Cron-based alternative (`0 3 * * * /sbin/zpool scrub tank`)

```bash
sudo crontab -l | cat - <(echo "0 3 * * * /sbin/zpool scrub tank") | sudo crontab -
```

### Docker on ZFS

```bash
sudo zfs create -o com.sun:auto-snapshot=false tank/docker
docker compose stop
sudo service docker stop
sudoedit /etc/docker/daemon.json
'add theese lines
{
  "storage-driver": "zfs"
}
backup necessary docker data and then remove'
sudo rm -rf /var/lib/docker
sudo ln -s /tank/docker /var/lib/docker
sudo service docker start
```

### TODO

- maybe need to create docker service trigger on ZFS mount?
  - <https://www.reddit.com/r/docker/comments/my6p90/docker_zfs_storage_driver_vs_storing_docker_data/>
  - <https://www.reddit.com/r/zfs/comments/10e0rkx/for_anyone_using_zfsol_with_docker/>
- weekly cron to backup compressed backup of zpool to 5th 2tb disk
- backup / and /boot volumes disk (emmc)

## tools

### arch

```bash
base="mc git btop ncdu tmux tree neovim neofetch"
docker="docker docker-compose"
sudo pacman -S $base $docker
sudo systemctl restart docker
```
