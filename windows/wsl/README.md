# WSL
## "These files might be harmful to your computer" fix
```pwsh
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\wsl.localhost" /f /v file  /t REG_DWORD /d 1
or 
Win+S -> `Internet Options` -> Security -> Local intranet -> Sites -> Advanced -> `\\wsl.localhost` -> Add
```
## [Get DISPLAY for old WSL (probably, useless now)](https://serverfault.com/q/47915)
```bash
ip r l default | awk '{print $3}'
```
## Optimize VHD (or https://github.com/microsoft/WSL/issues/4699)
```bash
wsl --shutdown
diskpart
select vdisk file="C:\Users\Admin\AppData\Local\Packages\CanonicalGroupLimited.UbuntuonWindows_79rhkp1fndgsc\LocalState\ext4.vhdx"
attach vdisk readonly
compact vdisk
detach vdisk
exit
```
## IP address
```bash
# wsl host [0]
hostname -I
ip a s eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'

# windows address
cat /etc/resolv.conf | grep nameserver | cut -d ' ' -f 2

# https://learn.microsoft.com/en-us/windows/wsl/networking#accessing-a-wsl-2-distribution-from-your-local-area-network-lan
netsh interface portproxy add v4tov4 listenport=5201 listenaddress=0.0.0.0 connectport=5201 connectaddress=$wsl_host
```
