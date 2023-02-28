# set new password for root
`passwd`

#arch
```bash
# create sudo user
export username="ogurez"
useradd -mG wheel $username
passwd $username

pacman -Suy neovim
EDITOR=nvim visudo
# uncomment wheel lines
```

#ubuntu
```bash
# create sudo user
export username="ogurez"
passwd
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
alias vim=nvim
sudo vim /etc/ssh/sshd_config
# ---
Port 2222
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM no
# ---
sudo systemctl reload ssh
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
export LANG=C.UTF-8  # server
# export LC_TIME=ru_RU.UTF-8
export LC_CTYPE=ru_RU.UTF-8  # https://stackoverflow.com/a/30480596/15844518
```
# tools
#arch
```bash
sudo pacman -S mc git btop docker docker-compose
```
