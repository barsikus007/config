# WSL
## "These files might be harmful to your computer" fix
```pwsh
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\wsl.localhost" /f /v file  /t REG_DWORD /d 1
or 
Win+S -> `Internet Options` -> Security -> Local intranet -> Sites -> Advanced -> `\\wsl.localhost` -> Add
```
