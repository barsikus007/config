# [Windows](../README.md)

## Pre-install

```powershell
# TODO
```

## Install

```powershell
# Clone
pwsh.exe
cd && git clone https://github.com/barsikus007/config --depth 1 && cd -
# Install/Update
# TODO remove sudo? and/or make universal configs\install.ps1 installer
cd ~\config\ && git pull && sudo .\windows\pwsh.ps1 && cd -
# idk which
cd ~\config\ && git pull && .\configs\install.ps1 && cd -
```

## Post-install

```powershell
#? https://wiki.archlinux.org/title/System_time#UTC_in_Microsoft_Windows
sudo reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /d 1 /t REG_DWORD /f
```

## Powershell lifehack to bypas security policy

```powershell
PowerShell.exe -ExecutionPolicy Bypass -File filename
```

## [Soft](./soft.md)

## [ROG G14](./rog14.md)

## PWSH cheatsheet

### Convert all mkv to mp4 with ffmpeg

```powershell
$oldvids = Get-ChildItem -Filter "*.mkv" -Recurse

foreach ($oldvid in $oldvids) {
    $newvid = [io.path]::ChangeExtension($oldvid, '.mp4')
    ffmpeg.exe -i $oldvid-y -s 960x544 -c:v copy -c:a aac $newvid
}
```

## QuickLook

### [Used Plugins](https://github.com/QL-Win/QuickLook/wiki/Available-Plugins)

- [stl](https://github.com/jeremyhart/QuickLook.Plugin.HelixViewer/releases)

## TODO

- install windows soft with auto update from winget (think about config sync of that apps)
- ask scoop maintaners about FAQ about tools with autoupdate
- `~/Documents/PowerShell/profile.ps1`
- winget
  - `https://builds.parsec.app/package/parsec-windows.exe`
  - `Parsec.Parsec`
- allow powershell profiles in wt.exe
- <https://github.com/ionuttbara/windows-defender-remover>
  - not tested
- <https://camo.studio/>
- scoop
  - aria2bug
    - scoop config aria2-options "--check-certificate false"
    - scoop config rm aria2-options
    - or
    - scoop config aria2-enabled false
    - scoop config rm aria2-enabled
    - or/and
    - aria2 disable alias
    - aria2 scoop tune params
  - scoop cleanup -a
  - scoop cache rm -a
- history file: `~\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt`
- winget installBehavior": "portablePackageMachineRoot", "portablePackageUserRoot", "preferences": "scope": "user"
- config fzf
- pwsh packages (move to 5.0?)
  - <https://github.com/farag2/Windows_Terminal/blob/main/Install_Modules.ps1>
- mingit cert config
  - `git config --global http.sslCAInfo "C:\\Users\\Admin\\scoop\\apps\\mingit\\current\\mingw64\\etc\\ssl\\certs\\ca-bundle.crt"`
- exclude autoupdate packages from scoop
- explorer like tabs in wt.exe
- powertoys pc config (without remaps)
- copy scoop/persist configs for apps
- auto wslhostpatcher
- notepad.exe -> Cascadia Code NF 12
- Test UWP VK client
  - `winget install laney -s msstore -e --accept-package-agreements`
  - <https://elorucov.github.io/laney/>
  - `9MSPLCXVN1M5`
  - <https://github.com/Elorucov/Laney-Avalonia/releases>
- Tweak windows
  - <https://github.com/farag2/Sophia-Script-for-Windows>
  - <https://win10tweaker.ru/twikinarium>
- netlimiter or windowsfirewallcontrol
- pwsh
  - pwsh 5 dont load profile and notice about pwsh 7
  - pwsh funcs $args broken?
  - config pwsh -nol
  - lazy eval of Test-Command
- unsorted dump from TG
  - fix powertoys rmc
  - fix dotnet
  - windows explorer path bar fix to old
  - diskpart windows нормальный

## Toggle new context menu (due to lack of 7zip and notepad++)

- disable `reg.exe add “HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32” /f`
- enable `reg.exe delete “HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}” /f`

## Beyond Compare crack <https://gist.github.com/rise-worlds/5a5917780663aada8028f96b15057a67>

```powershell
#Remove-Item "$env:appdata\Scooter Software\Beyond Compare 4\*.*" -Force -Confirm:$false
Remove-Item "$env:appdata\Scooter Software\Beyond Compare 4\BCState.xml" -Force -Confirm:$false
Remove-Item "$env:appdata\Scooter Software\Beyond Compare 4\BCState.xml.bak" -Force -Confirm:$false
#Remove-Item "$env:appdata\Scooter Software\Beyond Compare 4\BCSessions.xml" -Force -Confirm:$false
#Remove-Item "$env:appdata\Scooter Software\Beyond Compare 4\BCSessions.xml.bak" -Force -Confirm:$false
reg delete "HKCU\Software\Scooter Software\Beyond Compare 4" /v "CacheID" /f
```

## Edge fix "harm exe" notification

```reg
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge\ExemptDomainFileTypePairsFromFileTypeDownloadWarnings]
"1"="{\"file_extension\": \"exe\", \"domains\": [\"*\"]}"
```

### [Another shitty edge warning disabler](https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies#disable-download-file-type-extension-based-warnings-for-specified-file-types-on-domains)

## Shutdown commands

- `shutdown /t 0 /r`  # reload now
- `shutdown /t 0 /s /f`  # full shutdown

## WireGuard

- wireguard fix to make wg interfaces from public to private
  - <https://raw.githubusercontent.com/krair/cloud-tools/main/wireguard/Win_wg_adapters_to_private.ps1>
  - shorter but less universal version `Set-NetConnectionProfile -InterfaceAlias 'wg0' -NetworkCategory 'Private'`
- <https://www.procustodibus.com/blog/2021/03/wireguard-allowedips-calculator/>
  - `0.0.0.0/1, 128.0.0.0/2, 192.0.0.0/9, 192.128.0.0/11, 192.160.0.0/13, 192.169.0.0/16, 192.170.0.0/15, 192.172.0.0/14, 192.176.0.0/12, 192.192.0.0/10, 193.0.0.0/8, 194.0.0.0/7, 196.0.0.0/6, 200.0.0.0/5, 208.0.0.0/4, 224.0.0.0/3, ::/1, 8000::/1`

### WireSockUI

- install
  - `winget install NTKERNEL.WireSockVPNClient`
  - <https://github.com/wiresock/WireSockUI/releases>
- `AllowedApps = _msedge, _opera, code, copilot-agent-win, EpicGamesLauncher, EpicWebHelper, steam, steamwebhelper, mstsc`
- `AllowedIPs = 0.0.0.0/1, 128.0.0.0/1, ::/1, 8000::/1`

## Steam Lite

`steam -no-browser +open steam://open/minigameslist`

## Sound Normalization

Sound Source Settings -> Enhancements -> Loudness Equalization

## install hacks

### pass HW checks

```powershell
# SHIFT + F10

reg add HKLM\System\Setup\LabConfig /t reg_dword /d 0x00000001 /f /v BypassTPMCheck
reg add HKLM\System\Setup\LabConfig /t reg_dword /d 0x00000001 /f /v BypassSecureBootCheck
reg add HKLM\System\Setup\LabConfig /t reg_dword /d 0x00000001 /f /v BypassCPUCheck
reg add HKLM\System\Setup\LabConfig /t reg_dword /d 0x00000001 /f /v BypassRAMCheck
reg add HKLM\System\Setup\LabConfig /t reg_dword /d 0x00000001 /f /v BypassStorageCheck
```

### local account creation

```powershell
# SHIFT + F10
start ms-cxh:localonly
```

### [KMS](https://massgrave.dev)
