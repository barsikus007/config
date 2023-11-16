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

## ssh

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

## utf-8

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

## tools

### arch

```bash
base="mc git btop ncdu tmux tree neovim neofetch"
docker="docker docker-compose"
sudo pacman -S $base $docker
sudo systemctl restart docker
```
