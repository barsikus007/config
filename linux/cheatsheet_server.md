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

su $username
```

### ubuntu

```bash
# change root user passwd
sudo passwd root

# create sudo user
export username="ogurez"
# apt update && apt install adduser sudo -y
adduser $username --gecos ""
usermod -aG sudo $username

su $username
```

## SSH

### config sshd_config for security

```bash
cat <<-EOF | sudo tee /etc/ssh/sshd_config.d/99-security.conf >/dev/null
Port 2222
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
KbdInteractiveAuthentication no
EOF

sudo systemctl reload sshd
```

#### old (bad) method

```bash
``` bash
sshd_file=/etc/ssh/sshd_config
cp $sshd_file ~
sudo sed -i 's/^#Port/Port/' $sshd_file
sudo sed -i 's/^Port 22$/Port 2222/' $sshd_file
for param in {PermitRootLogin,PasswordAuthentication,ChallengeResponseAuthentication,KbdInteractiveAuthentication}; do sudo sed -i "s/^#$param/$param/" $sshd_file && sudo sed -i "s/^$param yes$/$param no/" $sshd_file; done
sudo systemctl reload sshd
```

##### for ubuntu 22.10 or newer

```bash
# check files in /etc/ssh/sshd_config.d/
sudo cat /etc/ssh/sshd_config.d/*
# fix all confilting config in that files or remove them
sudo rm -rf /etc/ssh/sshd_config.d/
# change ssh.socket config or follow `vim /usr/share/doc/openssh-server/README.Debian.gz`
sudo sed -i 's/^ListenStream=22$/ListenStream=2222/' /lib/systemd/system/ssh.socket
sudo systemctl daemon-reload
sudo systemctl restart ssh.socket
sudo reboot
```

### allow port forward ssh (used for minecraft a long time ago..)

```bash
cat <<-EOF | sudo tee /etc/ssh/sshd_config.d/10-port-forward.conf >/dev/null
AllowTcpForwarding yes
GatewayPorts yes
EOF

sudo systemctl reload sshd
```

## UTF-8

```bash
locale
locale -a
# if not C.UTF-8 exists
# Does C.UTF-8 needs to be generated?
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

# if no prebuilt kernel module
sudo apt install zfs-dkms -y
sudo reboot
sudo /sbin/modprobe zfs
```

### Commands

- [Clear arc cache](https://netpoint-dc.com/blog/zfs-caching-arc-l2arc-linux/)
  - `sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'`
- Add auto snapshot package
  - `sudo apt install zfs-auto-snapshot -y`
- Enable scrub timer
  - `sudo systemctl enable --now zfs-scrub-weekly@tank.timer`
  - Cron-based alternative (`0 3 * * * /sbin/zpool scrub tank`)
    - `sudo crontab -l | cat - <(echo "0 3 * * * /sbin/zpool scrub tank") | sudo crontab -`

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

### Docker on ZFS

```bash
sudo zfs create -o com.sun:auto-snapshot=false tank/docker
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

### SMB TODO (OpenZFS doesn't have all options of vanilla ZFS)

```bash
# sudo zfs get sharesmb tank/storage
sudo zfs set nbmand=on tank/storage
# sudo zfs share -o sharesmb=on tank/storage%storage
sudo zfs share smb tank/storage%storage
zfs get share.smb.all tank/storage%storage
```

### TODO

- maybe need to create docker service trigger on ZFS mount?
  - <https://www.reddit.com/r/docker/comments/my6p90/docker_zfs_storage_driver_vs_storing_docker_data/>
  - <https://www.reddit.com/r/zfs/comments/10e0rkx/for_anyone_using_zfsol_with_docker/>
- weekly cron to backup compressed backup of zpool to 5th 2tb disk
- backup / and /boot volumes disk (emmc)

## tools

### Docker

```bash
# install docker
curl -sSL https://get.docker.com | sh
# seems like it's not needed
# sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker; exit
```

#### Watchtower

```bash
docker run -d \
--name watchtower \
--restart always \
-v /var/run/docker.sock:/var/run/docker.sock \
containrrr/watchtower --cleanup --remove-volumes
```

### arch soft

```bash
# install config
sudo pacman -S git
cd && git clone https://github.com/barsikus007/config --depth 1 && cd -
cd ~/config/ && git pull && ./configs/install.sh && cd -
setup_arch

sudo pacman -S docker docker-compose
sudo systemctl restart docker
```
