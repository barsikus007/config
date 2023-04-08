# set new password for root
`passwd`

#arch
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

#ubuntu
```bash
# change root user passwd
passwd

# create sudo user
export username="ogurez"
adduser $username

usermod -aG sudo $username
passwd $username

su $username
```

# generate ssh-key
```bash
ssh-keygen -t rsa -f filename -P ""
ssh-copy-id -i filename.pub ogurez@192.168.0.228
```
# config sshd_config
``` bash
sudo nvim /etc/ssh/sshd_config
# ---
Port 2222
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM no
# ---
sudo systemctl reload sshd
```

# utf-8
```bash
locale -a
sudo apt install locales
# sudo locale-gen ru_RU.UTF-8
sudo locale-gen en_US.UTF-8
sudo locale-gen C.UTF-8
sudo update-locale
# WHICH ONE I SHOULD CHOOSE ?
sudo localectl set-locale LANG=C.UTF-8  # server ?
sudo localectl set-locale LANG=en_US.UTF-8  # desktop ?
# export LC_TIME=ru_RU.UTF-8
export LC_CTYPE=ru_RU.UTF-8  # https://stackoverflow.com/a/30480596/15844518
```
# tools
#arch
```bash
sudo pacman -S mc git btop ncdu docker docker-compose
sudo systemctl restart docker
```
