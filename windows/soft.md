# [Soft](./)

## WSA

- <https://github.com/LSPosed/MagiskOnWSALocal>
- `scoop install wsa-pacman`

## Other soft

- [system informer (process hacker)](https://systeminformer.sourceforge.io/nightly.php)
- [USB test software](https://www.heise.de/download/product/h2testw-50539/download)
- [USB Tree View](https://www.uwe-sieber.de/usbtreeview_e.html#download)
- [WiFiHotspot](https://mypublicwifi.com/publicwifi/en/index.html)
- [Shadow Defender](http://www.shadowdefender.com/download/Setup.exe)
  - VMACN-4MA3W-S4RHY-5HYT4-GZNN4
- [Virtual Monitor](https://www.amyuni.com/forum/viewtopic.php?t=3030)

## Office

- <https://massgrave.dev/>
- <https://support.microsoft.com/en-us/office/download-and-install-or-reinstall-microsoft-365-or-office-2021-on-a-pc-or-mac-4414eaaf-0478-48be-9c42-23adc4716658?ui=en-us&rs=en-us&ad=us>
- <https://officecdn.microsoft.com/pr/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/en-us/ProPlus2019Retail.img>
- <https://setup.office.com/>
- <https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=languagepack&language=ru-ru&platform=x86&source=O16LAP&version=O16GA>

## Player alternative to mpv

- [PotPlayer XpucT](https://win10tweaker.ru/forum/topic/potplayer-portable)
  - [Direct Link](https://jailbreakvideo.ru/Files/Portable%20PotPlayer.exe)

## TODO dxwebinstall

<https://www.microsoft.com/ru-ru/download/details.aspx?id=35>
<https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe>

## Torrent Edition

- VMware.WorkstationPlayer
- VMware.WorkstationPro
- or other virtual thing

## winget

<https://winstall.app/apps/{id}>

`winget install --id={id} -e -h`

### msstore

```powershell
# paint3d
winget install --id=9NBLGGH5FV99 -e --accept-package-agreements
# minecraft
winget install --id=9NBLGGH2JHXJ -e --accept-package-agreements
```

### CORE APPS

```powershell
winget upgrade --accept-source-agreements
winget install --id Microsoft.PowerShell -e -h
```

- Docker.DockerDesktop
- Parsec.Parsec
- SandboxiePlus.SandboxieClassic
- Google.QuickShare
- WireGuard.WireGuard

```powershell
# dotnet for some apps, 6 is for powertoys, others are for TODO
# sudo winget install --id=Microsoft.dotnetRuntime.3-x64 -e -h
# sudo winget install --id=Microsoft.dotnetRuntime.5-x64 -e -h
sudo winget install --id=Microsoft.dotnetRuntime.6-x64 -e -h
# Microsoft Visual C++ 14.0 or greater for some python packages
sudo winget install --id=Microsoft.VisualStudio.2022.BuildTools -e --override '--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 --quiet --wait'
```

// scoop probably broken

- AnyDeskSoftwareGmbH.AnyDesk
- Microsoft.PowerToys
- qBittorrent.qBittorrent
- ShareX.ShareX
- TorProject.TorBrowser
- quicklook

### GAMES

- Blizzard.BattleNet
- EpicGames.EpicGamesLauncher
- GOG.Galaxy
- Valve.Steam
- Ubisoft.Connect
- DolphinEmulator.Dolphin

### OTHER

- Nvidia.Broadcast
- Nvidia.CUDA
- Nvidia.GeForceExperience

// scoop probably broken

- IrfanSkiljan.IrfanView
- Oracle.JavaRuntimeEnvironment
- JetBrains.Toolbox
