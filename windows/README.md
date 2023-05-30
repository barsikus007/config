# Windows env
Powershell lifehack to bypas security policy
```pwsh
PowerShell.exe -ExecutionPolicy Bypass -File filename
```
## Sound Normailsation
Sound Source Settings -> Enhancements -> Loudness Equalization
## TODO
- ROG14 https://www.reddit.com/r/ZephyrusG14/comments/p63yct/how_do_i_disable_varibright_without_using_radeon/
- https://android.com/better-together/nearby-share-app/
- [USB test software](https://www.heise.de/download/product/h2testw-50539/download)
- config fzf (z)
- winget installBehavior": "portablePackageMachineRoot", "portablePackageUserRoot", "preferences": "scope": "user"
- auto wslhostpatcher
- edge fix "harm exe" notification:
```reg
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge\ExemptDomainFileTypePairsFromFileTypeDownloadWarnings]
"1"="{\"file_extension\": \"exe\", \"domains\": [\"*\"]}"
```
- chrome flag
  - edge://flags/#enable-parallel-downloading
  - opera://flags/#enable-parallel-downloading
- https://massgrave.dev
- powertoys to winget
- https://www.amyuni.com/forum/viewtopic.php?t=3030
- beyond compare + crack https://gist.github.com/rise-worlds/5a5917780663aada8028f96b15057a67
```pwsh
#rm "$env:appdata\Scooter Software\Beyond Compare 4\*.*" -Force -Confirm
rm "$env:appdata\Scooter Software\Beyond Compare 4\BCState.xml" -Force -Confirm
rm "$env:appdata\Scooter Software\Beyond Compare 4\BCState.xml.bak" -Force -Confirm
#rm "$env:appdata\Scooter Software\Beyond Compare 4\BCSessions.xml" -Force -Confirm
#rm "$env:appdata\Scooter Software\Beyond Compare 4\BCSessions.xml.bak" -Force -Confirm
reg delete "HKCU\Software\Scooter Software\Beyond Compare 4" /v "CacheID" /f

```
- gsudo vs sudo
- https://github.com/gerardog/gsudo#powershell-module
- notepad.exe -> Delugia 12
- shutdown /t 0 /r  # reload now
- shutdown /s /f /t 0  # full shutdown
- ROG G14
  - https://www.reddit.com/r/ZephyrusG14/comments/hldxcv/how_to_get_10_hours_battery/
  - https://discord.com/channels/736971456054952027/736971456650412114/784252533886418954
  - https://github.com/aredden/RestartGPU/
  - https://github.com/sammilucia/ASUS-G14-Debloating/
  - https://drive.google.com/file/d/1tsmKRIt1S2AUqp3S2pFVCtBNxXtQC3bE/view
- unlock hidden power functions
  - unknown source (reddit)
  - `powercfg.exe -attributes sub_processor perfboostmode -attrib_hide`
  - `powercfg.exe -attributes sub_disk 0b2d69d7-a2a1-449c-9680-f91c70521c60 -attrib_hide`
- common linux aliases to windows (like ll)
- winget install laney -s msstore
- new context menu
  - disable `reg.exe add “HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32” /f`
  - enable `reg.exe delete “HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}” /f`
- TunnlTo
  - whitelist `_msedge, _opera, code, copilot-agent-win, EpicGamesLauncher, EpicWebHelper, steam, steamwebhelper, mstsc`
  - AllowedIPs `0.0.0.0/1, 128.0.0.0/1, ::/1, 8000::/1`
  - DisallowedIPs `192.168.0.0/16`
  - https://www.procustodibus.com/blog/2021/03/wireguard-allowedips-calculator/ `0.0.0.0/1, 128.0.0.0/2, 192.0.0.0/9, 192.128.0.0/11, 192.160.0.0/13, 192.169.0.0/16, 192.170.0.0/15, 192.172.0.0/14, 192.176.0.0/12, 192.192.0.0/10, 193.0.0.0/8, 194.0.0.0/7, 196.0.0.0/6, 200.0.0.0/5, 208.0.0.0/4, 224.0.0.0/3, ::/1, 8000::/1`
- wireguard fix to make wg interfaces from public to private
  - https://raw.githubusercontent.com/krair/cloud-tools/main/wireguard/Win_wg_adapters_to_private.ps1
  - shorter but less universal version `Set-NetConnectionProfile -InterfaceAlias 'wg0' -NetworkCategory 'Private'`
- steam lite `steam -no-browser +open steam://open/minigameslist`
- WSA
- WSLg
- Tweak windows
  - https://github.com/farag2/Sophia-Script-for-Windows
  - https://win10tweaker.ru/twikinarium
- clink
- Consistent theming
  - https://github.com/Serendipity-Theme/windows-terminal
  - same theme for vscode
- netlimiter or windowsfirewallcontrol
- scoop bucket add dorado https://github.com/chawyehsu/dorado
- powertoys config
  - pc
  - laptop (with btns)

## other
## WSL
wsl --install -d Ubuntu
### TODO wslg
### TODO wslg config 120 fps

## WSA
https://github.com/barsikus007/MagiskOnWSA

## msstore
##paint3d
winget install --id=9NBLGGH5FV99 -e --accept-package-agreements
##minecraft
winget install --id=9NBLGGH2JHXJ -e --accept-package-agreements

## system informer (process hacker)
https://systeminformer.sourceforge.io/nightly.php

## shadow defender
VMACN-4MA3W-S4RHY-5HYT4-GZNN4
http://www.shadowdefender.com/download/Setup.exe

## office
https://support.microsoft.com/en-us/office/download-and-install-or-reinstall-microsoft-365-or-office-2021-on-a-pc-or-mac-4414eaaf-0478-48be-9c42-23adc4716658?ui=en-us&rs=en-us&ad=us
https://officecdn.microsoft.com/pr/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/en-us/ProPlus2019Retail.img
https://setup.office.com/
https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=languagepack&language=ru-ru&platform=x86&source=O16LAP&version=O16GA

## player
mpv TODO config
https://win10tweaker.ru/forum/topic/potplayer-portable
https://jailbreakvideo.ru/Files/Update%20Portable%20PotPlayer.exe

## TODO dxwebinstall
https://www.microsoft.com/ru-ru/download/details.aspx?id=35
https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe

## TODO drivers

## torrent
- //VMware.WorkstationPlayer
- //VMware.WorkstationPro
- or other virtual thing

## copy configs for apps


# winget
https://winstall.app/apps/{id}
## CORE APPS
```pwsh
winget upgrade --accept-source-agreements
# winget install pwsh -h
# winget install pwsh-preview -h
```
```pwsh
winget install --id=Docker.DockerDesktop -e -h
winget install --id=Mozilla.Firefox -e -h
winget install --id=Parsec.Parsec -e -h
winget install --id=Nvidia.RTXVoice -e -h
winget install --id=SandboxiePlus.SandboxieClassic -e -h
winget install --id=WireGuard.WireGuard -e -h
```
```pwsh
# dotnet for some apps, 6 is for powertoys, others are for TODO
# sudo winget install --id=Microsoft.dotnetRuntime.3-x64 -e -h
# sudo winget install --id=Microsoft.dotnetRuntime.5-x64 -e -h
sudo winget install --id=Microsoft.dotnetRuntime.6-x64 -e -h
# Microsoft Visual C++ 14.0 or greater for some python packages
sudo winget install --id=Microsoft.VisualStudio.2022.BuildTools -e --override '--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 --quiet --wait'
```
scoop probably broken
- AnyDeskSoftwareGmbH.AnyDesk
- Mozilla.Firefox
- Opera.Opera
- Microsoft.PowerToys
- Python.Python.3
- qBittorrent.qBittorrent
- ShareX.ShareX
- Telegram.TelegramDesktop
- TorProject.TorBrowser

## GAMES
```pwsh
winget install --id=Blizzard.BattleNet -e -h
winget install --id=EpicGames.EpicGamesLauncher -e -h
winget install --id=GOG.Galaxy -e -h
winget install --id=Valve.Steam -e -h
winget install --id=Ubisoft.Connect -e -h
```
DolphinEmulator.Dolphin

## BENCH
// scoop probably broken
- CPUID.CPU-Z
- CrystalDewWorld.CrystalDiskInfo
- CrystalDewWorld.CrystalDiskMark
- TechPowerUp.GPU-Z

## OTHER
```pwsh
winget install --id=OsirisDevelopment.BatteryBar -e -h
winget install --id=Nvidia.CUDA -e -h
winget install --id=Nvidia.GeForceExperience -e -h
```
// scoop probably broken
- IrfanSkiljan.IrfanView
- Oracle.JavaRuntimeEnvironment
- KDE.KDEConnect
- Notion.Notion
- SlackTechnologies.Slack
- Termius.Termius
- JetBrains.Toolbox
## Fix when install
```pwsh
# SHIFT + F10

reg add HKLM\System\Setup\LabConfig /v BypassTPMCheck /t reg_dword /d 0x00000001 /f
reg add HKLM\System\Setup\LabConfig /v BypassSecureBootCheck /t reg_dword /d 0x00000001 /f
reg add HKLM\System\Setup\LabConfig /v BypassCPUCheck /t reg_dword /d 0x00000001 /f
reg add HKLM\System\Setup\LabConfig /v BypassRAMCheck /t reg_dword /d 0x00000001 /f
reg add HKLM\System\Setup\LabConfig /v BypassStorageCheck /t reg_dword /d 0x00000001 /f
```
