# [cheatsheet](./)

## ssh

### [add git key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent?platform=linux)

```bash
ssh-keygen -t ed25519 -C "example@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
```

### Generate and upload SSH

```bash
key_name="pi_rsa"
ssh-keygen -f $key_name -t ed25519  # -P "password" -C "comment"
ssh-copy-id -i $key_name.pub username@192.168.0.123
ssh server
```

### Allow port forward ssh

```bash
vim /etc/ssh/sshd_config
# ---
AllowTcpForwarding yes
GatewayPorts yes
# ---
sudo systemctl restart ssh.service
```

## commands

### apt

```bash
base="mc duf git btop ncdu tmux tree neovim neofetch"
soft_to_purge="snapd"
sudo apt install $base -y
sudo apt purge $soft_to_purge -y
# show installed https://askubuntu.com/q/2389
apt-mark showmanual
# or better
zgrep 'Commandline: apt' /var/log/apt/history.log /var/log/apt/history.log.*.gz
# or
zgrep -E "Commandline: apt(|-get)" /var/log/apt/history.log*
```

### pacman

```bash
base="mc git btop ncdu tmux tree neovim neofetch"
soft_to_purge="snapd"
sudo pacman -S $base -y
sudo pacman -Rsn $soft_to_purge -y
```

### [Download "whole" site](https://pingvinus.ru/note/wget-download-sites) ([alt](https://superuser.com/q/1672776))

```bash
# set recursion depth manually
wget -r -k -l 7 -p -E -nc http://site.com/
# OR automatic
wget -mpEk http://site.com/
```

### Check size of files at folder

```bash
# current folder
du . -hcd 1 | sort -hr
# current folder with files (use apparent sizes, rather than disk usage)
du . -hacd 1 --apparent-size | sort -hr
# all files in that folder recursively
du . -ha | sort -hr
```

### Grep search in dir recursively

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

```bash
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

### wifite on fedora

```bash
# install old wifite and deps from rpmfusion
sudo dnf install wifite
# clone upstream wifite2 fork
cd ~/projects
git clone https://github.com/kimocoder/wifite2.git
```

### Fix of mount password remember checkbox

```bash
sudo patch /etc/pam.d/login login.patch
```
