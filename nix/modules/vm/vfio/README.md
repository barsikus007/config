# NixOS VFIO imperative steps

## Windows 10 ISO and setup

1. [LTSC](https://massgrave.dev/windows10_eol#windows-10-iot-enterprise-ltsc-2021)
2. [unattend.xml](https://schneegans.de/windows/unattend-generator/)
   1. [unattend-win10-iot-ltsc-vrt.xml](https://schneegans.de/windows/unattend-generator/view/?LanguageMode=Unattended&UILanguage=en-US&Locale=en-US&Keyboard=00000409&UseKeyboard2=true&Locale2=ru-RU&Keyboard2=00000419&GeoLocation=203&ProcessorArchitecture=amd64&BypassRequirementsCheck=true&UseConfigurationSet=true&ComputerNameMode=Custom&ComputerName=NIXOS-WIN10-VRT&CompactOsMode=Default&TimeZoneMode=Implicit&PartitionMode=Unattended&PartitionLayout=GPT&EspSize=300&RecoveryMode=None&DiskAssertionMode=Skip&WindowsEditionMode=Custom&ProductKey=QPM6N-7J2WJ-P88HH-P3YRH-YY74H&InstallFromMode=Automatic&PEMode=Default&UserAccountMode=Unattended&AccountName0=Admin&AccountDisplayName0=&AccountPassword0=&AccountGroup0=Administrators&AutoLogonMode=Own&PasswordExpirationMode=Unlimited&LockoutMode=Default&HideFiles=HiddenSystem&ShowFileExtensions=true&LaunchToThisPC=true&ShowEndTask=true&TaskbarSearch=Hide&TaskbarIconsMode=Default&DisableWidgets=true&HideTaskViewButton=true&ShowAllTrayIcons=true&DisableBingResults=true&StartTilesMode=Empty&StartPinsMode=Default&DisableDefender=true&DisableSmartScreen=true&EnableLongPaths=true&DeleteJunctions=true&HideEdgeFre=true&DisableEdgeStartupBoost=true&DisablePointerPrecision=true&EffectsMode=Default&DesktopIconsMode=Default&StartFoldersMode=Default&VirtIoGuestTools=true&WifiMode=Skip&ExpressSettings=DisableAll&LockKeysMode=Skip&StickyKeysMode=Default&ColorMode=Default&WallpaperMode=Default&LockScreenMode=Default&WdacMode=Skip)
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

## xml edits

- `sudo virsh edit win10`

### spice

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

## soft to install

- [SPICE guest tools](https://looking-glass.io/docs/B7/install_libvirt/#clipboard-synchronization)
  - [installer](https://www.spice-space.org/download.html#windows-binaries)
- [looking-glass-host](https://looking-glass.io/artifact/stable/host)

## IDDs

- <https://looking-glass.io/artifact/bleeding/idd>
  - also compile client from latest rev

## misc

- useful soft
  - [notepad++](https://notepad-plus-plus.org/downloads/)
  - [wiztree](https://www.diskanalyzer.com/download)
  - [everything](https://www.voidtools.com/downloads/)
  - [latest nvidia drivers](https://www.nvidia.com/en-us/drivers/)

### TODO

- somewhat kvmfr method doesn't work
- embed to autounattend.xml
  - updates from 19044.1288 to 6576 (OOBE:KB5026037, OS:KB5068781, NET:KB5066746)
  - useful soft installation
    - via scoop ?
      - embed it with preinstalled scoop apps ?
        - nix-scoop ???
  - nix unattend.iso builder ?
- <https://looking-glass.io/docs/B7/install_libvirt/#additional-tuning>
  - <https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Improving_performance_on_AMD_CPUs>
- <https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/wsim/distribution-shares-and-configuration-sets-overview#oem-folders>
