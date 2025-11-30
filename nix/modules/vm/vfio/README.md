# NixOS VFIO imperative steps

## Toggle GPU

- host on
  - `sudo modprobe -r vfio-pci && sudo modprobe nvidia{,_modeset,_uvm,_drm}`
- host off
  - `sudo modprobe -r nvidia{_drm,_uvm,_modeset,} && sudo modprobe vfio-pci`

## Windows 10 ISO and setup

1. [LTSC](https://massgrave.dev/windows10_eol#windows-10-iot-enterprise-ltsc-2021)
2. [unattend.xml](https://schneegans.de/windows/unattend-generator/)
   1. [unattend-win10-iot-ltsc-vrt.xml](https://schneegans.de/windows/unattend-generator/view/?LanguageMode=Unattended&UILanguage=en-US&Locale=en-US&Keyboard=00000409&UseKeyboard2=true&Locale2=ru-RU&Keyboard2=00000419&GeoLocation=203&ProcessorArchitecture=amd64&BypassRequirementsCheck=true&UseConfigurationSet=true&ComputerNameMode=Custom&ComputerName=NIXOS-WIN10-VRT&CompactOsMode=Default&TimeZoneMode=Implicit&PartitionMode=Unattended&PartitionLayout=GPT&EspSize=300&RecoveryMode=None&DiskAssertionMode=Skip&WindowsEditionMode=Custom&ProductKey=QPM6N-7J2WJ-P88HH-P3YRH-YY74H&InstallFromMode=Automatic&PEMode=Default&UserAccountMode=Unattended&AccountName0=Admin&AccountDisplayName0=&AccountPassword0=&AccountGroup0=Administrators&AutoLogonMode=Own&PasswordExpirationMode=Unlimited&LockoutMode=Default&HideFiles=HiddenSystem&ShowFileExtensions=true&LaunchToThisPC=true&ShowEndTask=true&TaskbarSearch=Hide&TaskbarIconsMode=Default&DisableWidgets=true&HideTaskViewButton=true&ShowAllTrayIcons=true&DisableBingResults=true&StartTilesMode=Empty&StartPinsMode=Default&DisableDefender=true&DisableSmartScreen=true&EnableLongPaths=true&DeleteJunctions=true&HideEdgeFre=true&DisableEdgeStartupBoost=true&DisablePointerPrecision=true&EffectsMode=Default&DesktopIconsMode=Default&StartFoldersMode=Default&VirtIoGuestTools=true&WifiMode=Skip&ExpressSettings=DisableAll&LockKeysMode=Skip&StickyKeysMode=Default&ColorMode=Default&WallpaperMode=Default&LockScreenMode=Default&SystemScript0=C%3A%5CWindows%5CSetup%5CScripts%5CInstall.ps1&SystemScriptType0=Ps1&WdacMode=Skip)
      1. remove `view/` from link above to edit or change to `iso/` to download iso packed file
3. [virtio-win](https://looking-glass.io/docs/B7/install_libvirt/#keyboard-mouse-display-audio)
   1. [mount on virtual machine and install](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso)
4. `irm https://get.activated.win | iex`

## virt-manager setup

- win10.qcow2 size in G
  - 15 minimalest
  - 20 minimal
  - 25 good
  - 30+ best
- pass needed devices from GPU iommu_group to vm
- add tpm-crb

## xml edits

- `sudo virsh edit win10`

### [spice](https://looking-glass.io/docs/B7/install_libvirt/#keyboard-mouse-display-audio)

- in `<devices>`
  - `<graphics type='spice' />`
    - added by default
  - in `<video>`
    - `/vid jd2dO` `<model type='vga'/>`
  - `/tablet d3d` `<input type='tablet'/>`
  - `<input type='mouse' bus='virtio'/>`
  - `<input type='keyboard' bus='virtio'/>`
  - `/memb d3dO` `<memballoon />`
    - `<memballoon model='none'/>`

#### [clipboard](https://looking-glass.io/docs/B7/install_libvirt/#clipboard-synchronization)

- added by default

```xml
<channel type='spicevmc'>
  <target type='virtio' name='com.redhat.spice.0'/>
  <address type='virtio-serial' controller='0' bus='0' port='1'/>
</channel>
```

### ivshmem

- `67108864` is 64M (for 2560x1440)

#### [kvmfr](https://looking-glass.io/docs/B7/ivshmem_kvmfr/)

- `ddO`

```xml
<domain type='kvm' xmlns:qemu='http://libvirt.org/schemas/domain/qemu/1.0'>
<qemu:commandline>
  <qemu:arg value="-device"/>
  <qemu:arg value="{'driver':'ivshmem-plain','id':'shmem0','memdev':'looking-glass'}"/>
  <qemu:arg value="-object"/>
  <qemu:arg value="{'qom-type':'memory-backend-file','id':'looking-glass','mem-path':'/dev/kvmfr0','size':67108864,'share':true}"/>
</qemu:commandline>
```

#### [shm](https://looking-glass.io/docs/B7/ivshmem_shm)

- fallback if kvmfr doesn't work
- in `<devices>`

```xml
<shmem name='looking-glass'>
  <model type='ivshmem-plain'/>
  <size unit='M'>64</size>
</shmem>
```

### [tuning](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Performance_tuning)

- [pin correct cores](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#CPU_pinning) to VM
  - left 2/4 cores/threads to host
- if `<cpu />` is from [AMD](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Improving_performance_on_AMD_CPUs)
  - specify `<topology />` and set `<feature policy='require' name='topoext'/>` inside

### [stealth](https://astrid.tech/2022/09/22/0/nixos-gpu-vfio/#:~:text=Anti-Anti-Cheat%20Aktion)

- `/\/<oc O` `<smbios mode="sysinfo"/>`

#### [bios](https://libvirt.org/formatdomain.html#smbios-system-information)

```shell
# in root domain
<sysinfo type='smbios'>
  <bios>
sudo dmidecode --type bios | awk  -F  ': ' '
/Vendor/              { printf "    <entry name=\"vendor\">%s</entry>\n", $2 }
/Version/             { printf "    <entry name=\"version\">%s</entry>\n", $2 }
/Release Date/        { printf "    <entry name=\"date\">%s</entry>\n", $2 }
/BIOS Revision/       { printf "    <entry name=\"release\">%s</entry>\n", $2 }
'
  </bios>
  <system>
sudo dmidecode --type system | awk  -F  ': ' '
/Manufacturer/        { printf "    <entry name=\"manufacturer\">%s</entry>\n", $2 }
/Product Name/        { printf "    <entry name=\"product\">%s</entry>\n", $2 }
/Version/             { printf "    <entry name=\"version\">%s</entry>\n", $2 }
/Serial Number/       { printf "    <entry name=\"serial\">%s</entry>\n", $2 }
/UUID/                { printf "    <entry name=\"uuid\">%s</entry>\n", $2 }
/SKU Number/          { printf "    <entry name=\"sku\">%s</entry>\n", $2 }
/Family/              { printf "    <entry name=\"family\">%s</entry>\n", $2 }
'
  </system>
  <baseBoard>
sudo dmidecode --type baseboard | awk  -F  ': ' '
/Manufacturer/        { printf "    <entry name=\"manufacturer\">%s</entry>\n", $2 }
/Product Name/        { printf "    <entry name=\"product\">%s</entry>\n", $2 }
/Version/             { printf "    <entry name=\"version\">%s</entry>\n", $2 }
/Serial Number/       { printf "    <entry name=\"serial\">%s</entry>\n", $2 }
/Asset Tag/           { printf "    <entry name=\"asset\">%s</entry>\n", $2 }
/Location In Chassis/ { printf "    <entry name=\"location\">%s</entry>\n", $2 }
/Family/              { printf "    <entry name=\"family\">%s</entry>\n", $2 }
'
  </baseBoard>
  <chassis>
sudo dmidecode --type chassis | awk  -F  ': ' '
/Manufacturer/        { printf "    <entry name=\"manufacturer\">%s</entry>\n", $2 }
/Version/             { printf "    <entry name=\"version\">%s</entry>\n", $2 }
/Serial Number/       { printf "    <entry name=\"serial\">%s</entry>\n", $2 }
/Asset Tag/           { printf "    <entry name=\"asset\">%s</entry>\n", $2 }
/SKU Number/          { printf "    <entry name=\"sku\">%s</entry>\n", $2 }
'
  </chassis>
</sysinfo>
```

## soft to install

- [SPICE guest tools](https://looking-glass.io/docs/B7/install_libvirt/#clipboard-synchronization)
  - [installer](https://www.spice-space.org/download/windows/spice-guest-tools/spice-guest-tools-latest.exe)
    - `sudo *.exe /S`
- [looking-glass-host](https://looking-glass.io/artifact/stable/host)
  - `unzip | sudo *.exe /S`
  - or use [IDD version](https://looking-glass.io/artifact/bleeding/idd)
    - also compile client from latest rev

## misc

- useful soft
  - [notepad++](https://notepad-plus-plus.org/downloads/)
  - [wiztree](https://www.diskanalyzer.com/download)
  - [everything](https://www.voidtools.com/downloads/)
  - [latest nvidia drivers](https://www.nvidia.com/en-us/drivers/)
    - [CLI](https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/windows.html)

### TODO

- rewrite `xml edits` section to `virt-xml win10 --edit` or `nixvirt` or `nixos-vfio qemu` options
- virtio-net
- embed to autounattend.xml
  - useful soft installation
    - via scoop ?
      - embed it with preinstalled scoop apps into `$OEM$\$1\Users\Admin\scoop` ?
        - nix-scoop ???
  - nix unattend.iso builder ?
- <https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/wsim/distribution-shares-and-configuration-sets-overview#oem-folders>

#### [windows update ISO](https://gravesoft.dev/update-windows-iso)

- [WIN10UI](https://github.com/mariahlamb31/BatUtil/tree/27ab2d01e2d2cf47c87835c90a0991ca4d7c5f64/W10UI)
- `nix-shell -p aria2 cabextract wimlib chntpw cdrkit`
- [win10 LTSC](https://uupdump.net/known.php?q=category:w10-21h2)
  - [Feature](https://uupdump.net/selectlang.php?id=1f41c0e5-e142-4636-ba48-e333cf9f14dc)
  - [NET](https://www.catalog.update.microsoft.com/Search.aspx?q=3.5+-4.8.1+22H2+1903+Updates+x64)
  - pinned 2025-11-30 updates from 19044.1288 to 6576
    - [Cum KB5068781](https://www.catalog.update.microsoft.com/Search.aspx?q=KB5068781+LTSB+x64)
      - [SSU KB5031539](https://www.catalog.update.microsoft.com/Search.aspx?q=KB5031539+LTSB+x64)
    - [NET KB5066746](https://www.catalog.update.microsoft.com/Search.aspx?q=KB5066746+x64)
    - OOBE KB5026037
  - drivers
    - [nvidia](https://www.nvidia.com/en-us/drivers/)
      - `no 206 10`
        - [581.80](https://www.nvidia.com/en-us/drivers/details/257496/)
          - click on latest game drivers, they are the same lol (from GTX 7XX)


#### scoop

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
irm https://get.scoop.sh | iex

irm https://raw.githubusercontent.com/barsikus007/config/blob/master/windows/scoop/00Bootstrap.ps1 | iex
irm https://raw.githubusercontent.com/barsikus007/config/blob/master/windows/scoop/01LTSC.ps1 | iex

irm https://raw.githubusercontent.com/barsikus007/config/blob/master/windows/scoop/10Shell.ps1 | iex
irm https://raw.githubusercontent.com/barsikus007/config/blob/master/windows/scoop/11ShellHeavy.ps1 | iex

irm https://raw.githubusercontent.com/barsikus007/config/blob/master/windows/scoop/20SoftHighPriority.ps1 | iex
```
