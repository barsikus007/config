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
soft_to_install="mc curl neofetch"
soft_to_purge="snapd"
sudo apt install $soft_to_install -y
sudo apt purge $soft_to_purge -y
```
### Download "whole" site
```bash
wget -r -k -l 7 -p -E -nc http://site.com/
# OR
wget -mpEk -l 7 http://site.com/
```
### Check folder with size
```bash
du . -hcd 1 | sort -hr
du . -ha | sort -hr
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
# spams f calls
f(){ f | f& }; f
# redirect yes output to "no" file
yes > no
```
