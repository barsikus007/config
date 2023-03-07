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
