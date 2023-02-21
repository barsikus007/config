# cheatsheet
## screen todo tmux
### Connect and detach from screen
```bash
screen -ls
Ctrl+A Ctrl+D
screen -r
screen -X -S id quit
```
### Enable mouse scrolling and scroll
```bash
nano ~/.screenrc
bar history scrolling
termcapinfo xterm* ti@:te@
```
### and save screen scroll config
```bash
screen -c ~/.screenrc
export SCREENRC="~/.screenrc"
```

## ssh
### Generate and upload SSH
```bash
ssh-keygen -t rsa -P ""
ssh-copy-id -i pi_rsa.pub username@192.168.0.123
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
