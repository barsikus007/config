# [Windows](../README.md)

## Powershell lifehack to bypas security policy

```powershell
PowerShell.exe -ExecutionPolicy Bypass -File filename
```

## Install config (TODO move to install.ps1)

`.\windows\pwsh.ps1`

## [Soft](soft.md)

## [ROG G14](rog14.md)

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

- `~/Documents/PowerShell/profile.ps1`
- winget
  - `https://builds.parsec.app/package/parsec-windows.exe`
  - `Parsec.Parsec`
  - `Google.NearbyShare`
- allow powershell profiles in wt.exe
- <https://github.com/ionuttbara/windows-defender-remover>
  - not tested
- <https://camo.studio/>
- scoop aria2bug
  - scoop config aria2-options "--check-certificate false"
  - scoop config rm aria2-options
  - or
  - scoop config aria2-enabled false
  - scoop config rm aria2-enabled
- history file: `~\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt`
- winget installBehavior": "portablePackageMachineRoot", "portablePackageUserRoot", "preferences": "scope": "user"
- config fzf (z)
- pwsh packages (move to 5.0?)
  - <https://github.com/farag2/Windows_Terminal/blob/main/Install_Modules.ps1>
- mingit cert config
  - `git config --global http.sslCAInfo "C:\\Users\\Admin\\scoop\\apps\\mingit\\current\\mingw64\\etc\\ssl\\certs\\ca-bundle.crt"`
- install python from version repo
- exclude autoupdate packages from scoop
- WSA soft
- explorer like tabs in wt.exe
- powertoys pc config (without remaps)
- copy scoop/persist configs for apps
- auto wslhostpatcher
- notepad.exe -> Delugia 12
- Test UWP VK client
  - `winget install laney -s msstore -e --accept-package-agreements`
  - <https://elorucov.github.io/laney/>
  - `9MSPLCXVN1M5`
- Tweak windows
  - <https://github.com/farag2/Sophia-Script-for-Windows>
  - <https://win10tweaker.ru/twikinarium>
- Consistent theming
  - <https://github.com/Serendipity-Theme/windows-terminal>
  - same theme for vscode
- netlimiter or windowsfirewallcontrol

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

## Shutdown commands

- `shutdown /t 0 /r`  # reload now
- `shutdown /t 0 /s /f`  # full shutdown

## WireGuard

- wireguard fix to make wg interfaces from public to private
  - <https://raw.githubusercontent.com/krair/cloud-tools/main/wireguard/Win_wg_adapters_to_private.ps1>
  - shorter but less universal version `Set-NetConnectionProfile -InterfaceAlias 'wg0' -NetworkCategory 'Private'`
- <https://www.procustodibus.com/blog/2021/03/wireguard-allowedips-calculator/>
  - `0.0.0.0/1, 128.0.0.0/2, 192.0.0.0/9, 192.128.0.0/11, 192.160.0.0/13, 192.169.0.0/16, 192.170.0.0/15, 192.172.0.0/14, 192.176.0.0/12, 192.192.0.0/10, 193.0.0.0/8, 194.0.0.0/7, 196.0.0.0/6, 200.0.0.0/5, 208.0.0.0/4, 224.0.0.0/3, ::/1, 8000::/1`

### TunnlTo

- whitelist `_msedge, _opera, code, copilot-agent-win, EpicGamesLauncher, EpicWebHelper, steam, steamwebhelper, mstsc`
- AllowedIPs `0.0.0.0/1, 128.0.0.0/1, ::/1, 8000::/1`
- DisallowedIPs `192.168.0.0/16`

## Steam Lite

`steam -no-browser +open steam://open/minigameslist`

## Sound Normalisation

Sound Source Settings -> Enhancements -> Loudness Equalization

## Fix HW checks when install

```powershell
# SHIFT + F10

reg add HKLM\System\Setup\LabConfig /v BypassTPMCheck /t reg_dword /d 0x00000001 /f
reg add HKLM\System\Setup\LabConfig /v BypassSecureBootCheck /t reg_dword /d 0x00000001 /f
reg add HKLM\System\Setup\LabConfig /v BypassCPUCheck /t reg_dword /d 0x00000001 /f
reg add HKLM\System\Setup\LabConfig /v BypassRAMCheck /t reg_dword /d 0x00000001 /f
reg add HKLM\System\Setup\LabConfig /v BypassStorageCheck /t reg_dword /d 0x00000001 /f
```

## [KMS](https://massgrave.dev)
