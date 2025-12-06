# NixOS VFIO imperative steps

codename `Windows-Resurrect`

## Toggle GPU

- host on
  - `sudo modprobe -r vfio-pci && sudo modprobe nvidia{,_modeset,_uvm,_drm}`
- host off
  - `sudo modprobe -r nvidia{_drm,_uvm,_modeset,} && sudo modprobe vfio-pci`

## Windows 10 ISO and setup

1. [LTSC](https://massgrave.dev/windows10_eol#windows-10-iot-enterprise-ltsc-2021)
2. `nix build ./nix#windowsBootstrapIso -o unattend-win10-iot-ltsc-vrt.iso --print-build-logs` ([content](../../../packages/windows/default.nix))
   1. mount it
   2. [also mount this iso on virtual machine to install VM tools](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso)
3. run in pwsh **as user** `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser; irm https://raw.githubusercontent.com/barsikus007/config/refs/heads/master/windows/installOnWin10LTSC.ps1 | iex`([content](../../../../windows/installOnWin10LTSC.ps1))
   1. optional tweaks `irm https://raw.githubusercontent.com/barsikus007/config/refs/heads/master/windows/99Tweaks.ps1 | iex` ([content](../../../../windows/99Tweaks.ps1))
4. [soft to install](../../../packages/windows/AdditionalVMSetup.ps1)

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

#### [virtio-net](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Virtio_network)

- change `model` `type` to `virtio`

```xml
<interface type="network">
  ...
  <model type="virtio"/>
  ...
</interface>
```

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

### [FS](https://wiki.archlinux.org/title/Libvirt#Virtio-FS)

- `& "C:\Program Files\Virtio-Win\VioFS\virtiofs.exe" -t Data -m D:`
- `& "C:\Program Files\Virtio-Win\VioFS\virtiofs.exe" -t System -m S:`

## misc

- useful soft
  - [notepad++](https://notepad-plus-plus.org/downloads/)
  - [wiztree](https://www.diskanalyzer.com/download)
  - [everything](https://www.voidtools.com/downloads/)
  - [latest nvidia drivers](https://www.nvidia.com/en-us/drivers/)
    - [CLI](https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/windows.html)

### TODO

- rewrite `xml edits` section to `virt-xml win10 --edit` or `nixvirt` or `nixos-vfio qemu` options
  - or [virsh](https://wiki.archlinux.org/title/Libvirt#virsh)
- somehow optionally add `installOnWin10LTSC.ps1` and `99Tweaks.ps1` to unattend script
  - via nix ?
- `installOnWin10LTSC.ps1` could fail if `scoop` isn't in PATH FOR SOME FUCKING WINDOWS REASON

### [windows update ISO](https://gravesoft.dev/update-windows-iso)

- `nix-shell -p aria2 cabextract wimlib chntpw cdrkit`
- [WIN10UI](https://github.com/mariahlamb31/BatUtil/tree/27ab2d01e2d2cf47c87835c90a0991ca4d7c5f64/W10UI)
  - 1h50m and 30-50G needed to build in VM (50m on host)
- [win10 LTSC](https://uupdump.net/known.php?q=category:w10-21h2)
  - [pinned 2025-11-30 updates from 19044.1288 to 6576](https://uupdump.net/get.php?id=1f41c0e5-e142-4636-ba48-e333cf9f14dc&pack=en-us&edition=core%3Bprofessional)
    - [NET](https://www.catalog.update.microsoft.com/Search.aspx?q=3.5+-4.8.1+22H2+1903+Updates+x64)
    - msus
      - [Cum KB5068781](https://www.catalog.update.microsoft.com/Search.aspx?q=KB5068781+LTSB+x64)
        - [SSU KB5031539](https://www.catalog.update.microsoft.com/Search.aspx?q=KB5031539+LTSB+x64)
      - [NET KB5066746](https://www.catalog.update.microsoft.com/Search.aspx?q=KB5066746+x64)
      - OOBE KB5026037
    - drivers
      - [nvidia](https://www.nvidia.com/en-us/drivers/)
        - `no 206 10`
          - [581.80](https://www.nvidia.com/en-us/drivers/details/257496/)
            - click on latest game drivers, they are the same lol (from GTX 7XX)
            - [cli]
              - `7zz x *-win10-win11-64bit-international-dch-whql.exe Display.Driver NVI2 EULA.txt ListDevices.txt setup.cfg setup.exe -odrivers`
              - `.\setup.exe -s -n Display.Driver -log:c:\logs -loglevel:6`
              - `-log:logs`
        - [cab](https://www.catalog.update.microsoft.com/Search.aspx?q=nvidia%2021H2)
          - `32.0.15.8134`

```shell
UPDATE_ID=1f41c0e5-e142-4636-ba48-e333cf9f14dc
mkdir "win10-ltsc-$UPDATE_ID"
cd "win10-ltsc-$UPDATE_ID"
aria2c -x16 -s16 -j5 -c -R -i <(curl -s "https://uupdump.net/get.php?id=$UPDATE_ID&pack=en-us&edition=core%3Bprofessional&aria2=2" | grep --extended-regexp "(Windows10|SSU)" --context 2 --no-group-separator)
wget "https://raw.githubusercontent.com/mariahlamb31/BatUtil/27ab2d01e2d2cf47c87835c90a0991ca4d7c5f64/W10UI/W10UI.cmd"

BACKUP_DIR=/run/media/ogurez/NAS/Desktop/1VM/qcows/win10-1st
mkdir -p "$BACKUP_DIR"
sudo sh -c "cp /var/lib/libvirt/images/* $BACKUP_DIR"
sudo cp /var/lib/libvirt/qemu/win10.xml "$BACKUP_DIR"
```
