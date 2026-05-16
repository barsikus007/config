# [Ubuntu](./README.md)

## set new password for root

```shell
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

### add github user key to authorized

```shell
mkdir --parent ~/.ssh && curl https://github.com/barsikus007.keys --output - >> ~/.ssh/authorized_keys
```

### config sshd_config for security

```shell
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

```shell
sshd_file=/etc/ssh/sshd_config
cp $sshd_file ~
sudo sed -i 's/^#Port/Port/' $sshd_file
sudo sed -i 's/^Port 22$/Port 2222/' $sshd_file
for param in {PermitRootLogin,PasswordAuthentication,ChallengeResponseAuthentication,KbdInteractiveAuthentication}; do sudo sed -i "s/^#$param/$param/" $sshd_file && sudo sed -i "s/^$param yes$/$param no/" $sshd_file; done
sudo systemctl reload sshd
```

##### for ubuntu 22.10 or newer

```shell
# check files in /etc/ssh/sshd_config.d/
sudo cat /etc/ssh/sshd_config.d/*
# fix all confilting config in that files or remove them
sudo rm -rf /etc/ssh/sshd_config.d/
# change ssh.socket config or follow `nvim /usr/share/doc/openssh-server/README.Debian.gz`
sudo sed -i 's/^ListenStream=22$/ListenStream=2222/' /lib/systemd/system/ssh.socket
sudo systemctl daemon-reload
sudo systemctl restart ssh.socket
sudo reboot
```

### allow port forward ssh (used for minecraft a long time ago..)

```shell
cat <<-EOF | sudo tee /etc/ssh/sshd_config.d/10-port-forward.conf >/dev/null
AllowTcpForwarding yes
GatewayPorts yes
EOF

sudo systemctl reload sshd
```

## UTF-8

```shell
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

## Set timezone

`sudo timedatectl set-timezone Europe/Moscow`

## ZFS

### Install

```shell
sudo apt install zfsutils-linux -y

# if no prebuilt kernel module
sudo apt install zfs-dkms -y
sudo reboot
sudo /sbin/modprobe zfs
```

### Commands

- Add auto snapshot package
  - `sudo apt install zfs-auto-snapshot -y`
- Enable scrub timer
  - `sudo systemctl enable --now zfs-scrub-weekly@tank.timer`
  - Cron-based alternative (`0 3 * * * /sbin/zpool scrub tank`)
    - `sudo crontab -l | cat - <(echo "0 3 * * * /sbin/zpool scrub tank") | sudo crontab -`

### Docker on ZFS

```shell
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

## tools

### Docker

```shell
#? install
curl -sSL https://get.docker.com | sh
#? seems like it's not needed
# sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker; exit
```
