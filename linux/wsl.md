# WSL

```powershell
wsl --install
wsl --update
```

## [WSLg 120+ fps](https://github.com/microsoft/wslg/wiki/Controlling-WSLg-frame-rate)

`C:\ProgramData\Microsoft\WSL\.wslgconfig`

```ini
[system-distro-env]
WESTON_RDP_MONITOR_REFRESH_RATE=120
```

## "These files might be harmful to your computer" fix

```powershell
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\wsl.localhost" /f /v file  /t REG_DWORD /d 1
or
Win+S -> `Internet Options` -> Security -> Local intranet -> Sites -> Advanced -> `\\wsl.localhost` -> Add
```

## [Get DISPLAY for old WSL (probably, useless now)](https://serverfault.com/q/47915)

```bash
ip r l default | awk '{print $3}'
```

## Optimize VHD (or <https://github.com/microsoft/WSL/issues/4699>)

REPLACE "Admin" WITH YOUR WINDOWS USERNAME

```powershell
wsl --shutdown
diskpart

select vdisk file="C:\Users\Admin\AppData\Local\Packages\CanonicalGroupLimited.UbuntuonWindows_79rhkp1fndgsc\LocalState\ext4.vhdx"
attach vdisk readonly
compact vdisk
detach vdisk
exit
```

## Forward ports to WSL

```bash
# wsl host [0]
hostname -I
ip a s eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'

# windows address
cat /etc/resolv.conf | grep nameserver | cut -d ' ' -f 2
# or
ipconfig.exe

# https://learn.microsoft.com/en-us/windows/wsl/networking#accessing-a-wsl-2-distribution-from-your-local-area-network-lan
netsh.exe interface portproxy add v4tov4 listenport=19000 listenaddress=0.0.0.0 connectport=19000 connectaddress=$wsl_host

# remove
netsh.exe interface portproxy delete v4tov4 listenport=19000 listenaddress=0.0.0.0
```

## [Mount external drive to WSL](https://learn.microsoft.com/en-us/windows/wsl/wsl2-mount-disk)
