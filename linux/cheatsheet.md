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
nano /etc/ssh/sshd_config
AllowTcpForwarding yes
GatewayPorts yes
sudo systemctl restart ssh.service
```

## commands
### Download "whole" site
```bash
wget -r -k -l 7 -p -E -nc http://site.com/
OR
wget -mpEk -l 7 http://site.com/
```
### Check folder with size
```bash
du . -hcd 1 | sort -hr
du . -ha | sort -hr
```
### Bleachbit clear
```bash
sudo bleachbit --list | grep -E "[a-z0-9_\-]+\.[a-z0-9_\-]+" | grep -v system.free_disk_space | xargs sudo bleachbit --clean
```
### linux fork bomb
```bash
f(){ f | f& }; f
yes > no
```
### show motd
```bash
cat /var/run/motd.dynamic
#or
for i in /etc/update-motd.d/*; do if [ "$i" != "/etc/update-motd.d/98-fsck-at-reboot" ]; then $i; fi; done
```
### kill died terminals
```bash
ps aux | grep sshd | grep "\w*@pts/.*" | awk {'print $2'} | xargs kill -9
```
### apt
```bash
sudo apt install curl mc neofetch -y
sudo apt purge snapd -y
```
### говночистка
```bash
sudo crontab -e

0 0 * * * sh -c "truncate -s 0 /var/lib/docker/containers/*/*-json.log"
0 0 * * * bleachbit --list | grep -E "[a-z0-9_\-]+\.[a-z0-9_\-]+" | xargs bleachbit --clean
```
