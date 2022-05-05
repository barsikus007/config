# TODO
```pwsh
PowerShell.exe -ExecutionPolicy Bypass -File filename
```
- [ ] WSA
- [ ] WSLg
- [ ] Tweak windows
- [ ] clink
- [ ] autoinstall pwsh script
- [ ] starship fix custom git command
- [ ] starship design
- [ ] starship fix character on exit
- [ ] starship Administrator to root
- [ ] pwsh aliases
- [ ] nvim config
- [ ] https://www.youtube.com/watch?v=FW2X1CXrU1w
- [ ] git clone https://github.com/NvChad/NvChad ~\.config\nvim --depth 1
- [ ] fzf
- [ ] psfzf
- [ ] z
- [ ] pwsh.exe -NoLogo vscode

# other
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

## process hacker
https://processhacker.sourceforge.io/nightly.php

## shadow defender
VMACN-4MA3W-S4RHY-5HYT4-GZNN4
http://www.shadowdefender.com/download/Setup.exe

## office
https://support.microsoft.com/en-us/office/download-and-install-or-reinstall-microsoft-365-or-office-2021-on-a-pc-or-mac-4414eaaf-0478-48be-9c42-23adc4716658?ui=en-us&rs=en-us&ad=us
https://officecdn.microsoft.com/pr/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/en-us/ProPlus2019Retail.img
https://setup.office.com/
https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=languagepack&language=ru-ru&platform=x86&source=O16LAP&version=O16GA

## multimc
https://multimc.org/#Download

## player
mpv TODO config
https://win10tweaker.ru/forum/topic/potplayer-portable
https://jailbreakvideo.ru/Files/Update%20Portable%20PotPlayer.exe

## TODO dotnet 35 5

## TODO dxwebinstall

## TODO drivers

## torrent
//VMware.WorkstationPlayer
//VMware.WorkstationPro
or other virtual thing

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
# quiet argument is optional
sudo winget install --id=Microsoft.VisualStudio.2022.BuildTools -e --override '--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 --quiet'
```
// scoop probably broken
AnyDeskSoftwareGmbH.AnyDesk
Mozilla.Firefox
Opera.Opera
Microsoft.PowerToys
Python.Python.3
qBittorrent.qBittorrent
ShareX.ShareX
Telegram.TelegramDesktop
TorProject.TorBrowser

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
CPUID.CPU-Z
CrystalDewWorld.CrystalDiskInfo
CrystalDewWorld.CrystalDiskMark
TechPowerUp.GPU-Z

## OTHER
```pwsh
winget install --id=OsirisDevelopment.BatteryBar -e -h
winget install --id=Nvidia.CUDA -e -h
winget install --id=Nvidia.GeForceExperience -e -h
```
// scoop probably broken
IrfanSkiljan.IrfanView
Oracle.JavaRuntimeEnvironment
JetBrains.Toolbox
KDE.KDEConnect
Notion.Notion
Termius.Termius
SlackTechnologies.Slack
