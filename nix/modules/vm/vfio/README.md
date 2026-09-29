# [NixOS Windows VM with VFIO](../../../README.md)

codename `Windows-Resurrect`

## toggle GPU

- `dgpu_<tab>` will show my functions (now in `g14.sh`)

## Windows 10 ISO and setup

1. [LTSC](https://massgrave.dev/windows10_eol#windows-10-iot-enterprise-ltsc-2021)
   - `virsh attach-disk win10 --config --type cdrom --targetbus sata /run/media/ogurez/NAS/backups/drives/Ventoy/ventoy/ISO/Windows/en-us_windows_10_iot_enterprise_ltsc_2021_x64_dvd_257ad90f.iso sda`
   - optional integrate updates/drivers (see below)
2. `nix build ./nix#windows-bootstrapIso --out-link unattend-win10-iot-ltsc-vrt.iso --print-build-logs` ([content](../../../packages/windows/default.nix))
   - `virsh attach-disk win10 --config --type cdrom --targetbus sata ~/config/unattend-win10-iot-ltsc-vrt.iso sdb`
3. launch and press key at `Press any key to boot from CD or DVD......` screen
   - `virsh start win10 && for i in {1..10}; do sleep 1; virsh send-key win10 KEY_SPACE; done`
4. wait
   - SSH is available! `ssh Admin@192.168.122.120 -o StrictHostKeychecking=no -o UserKnownHostsFile=/dev/null -o ConnectionAttempts=60`
   - unmount installation media (will be reset by NixVirt on rebuild otherwise)
      - `virsh detach-disk win10 --config sda`
      - `virsh detach-disk win10 --config sdb`
5. run in pwsh **as user** `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser; irm https://raw.githubusercontent.com/barsikus007/config/refs/heads/master/windows/installOnWin10LTSC.ps1 | iex`([content](../../../../windows/installOnWin10LTSC.ps1))
   1. wait for UAC prompt and agree
   2. optional tweaks: launch `sudo pwsh.exe` and run `irm https://raw.githubusercontent.com/barsikus007/config/refs/heads/master/windows/99Tweaks.ps1 | iex` ([content](../../../../windows/99Tweaks.ps1))

## [FS](https://wiki.archlinux.org/title/Libvirt#Virtio-FS)

- system disk declared in [disko](../../hosts/ROG14/disk-config.nix)
  - size recommendations in G
    - 15G minimalest
    - 20G minimal
    - 25G good
    - 30G+ best
- `& "C:\Program Files\Virtio-Win\VioFS\virtiofs.exe" -t Data -m D:`
- `& "C:\Program Files\Virtio-Win\VioFS\virtiofs.exe" -t System -m S:`

## libvirt domains is [managed by NixVirt](./win10.nix)

`virsh edit win10` is only good for experiments - the next switch overwrites it

```shell
virsh dumpxml --inactive win10 > /tmp/live-win10.xml && code --diff --reuse-window /tmp/live-win10.xml $(nix eval --raw './nix#nixosConfigurations.ROG14.config.virtualisation.libvirt.connections."qemu:///system".domains' --apply 'ds: (builtins.head ds).definition')
```

## [windows update ISO](https://gravesoft.dev/update-windows-iso)

- `nix shell nixpkgs#{aria2,cabextract,wimlib,chntpw,cdrkit}`
- [WIN10UI](https://github.com/abbodi1406/BatUtil/tree/master/W10UI)
  - 1h50m and 30-50G needed to build in VM (50m on host)
- [win10 LTSC](https://uupdump.net/known.php?q=category:w10-21h2)
  - [pinned 2025-11-30 updates from 19044.1288 to 7727](https://uupdump.net/get.php?id=e19e2137-6c56-484d-ac12-1c06034b23a1&pack=en-us&edition=core%3Bprofessional)
    - [NET](https://www.catalog.update.microsoft.com/Search.aspx?q=3.5+-4.8.1+22H2+1903+Updates+x64)
    - `Drivers/OS`
      - [nvidia](https://www.nvidia.com/en-us/drivers/)
        - `no 206 10`
          - [617.14](https://www.nvidia.com/en-us/drivers/details/279804/)
            - click on latest game drivers, they are the same lol (from GTX 7XX)
            - for W10UI
              - `7zz x *-win10-win11-64bit-international-dch-whql.exe Display.Driver/* -oDrivers/OS`
            - install via [CLI](https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/windows.html)
              - `7zz x *-win10-win11-64bit-international-dch-whql.exe Display.Driver NvApp NVI2 EULA.txt ListDevices.txt setup.cfg setup.exe -odrivers`
              - `.\setup.exe -s -n Display.Driver -log:c:\logs -loglevel:6`
                - `-log:.\logs`
        - cab version from microsoft updates isn't suitable for laptops

```shell
UPDATE_ID=e19e2137-6c56-484d-ac12-1c06034b23a1
mkdir "win10-ltsc-$UPDATE_ID"
cd "win10-ltsc-$UPDATE_ID"
aria2c --max-connection-per-server=16 --split=16 --max-concurrent-downloads=5 --continue --remote-time --input-file <(curl --silent "https://uupdump.net/get.php?id=$UPDATE_ID&pack=en-us&edition=core%3Bprofessional&aria2=2" | grep --extended-regexp "(Windows10|SSU)" --context 2 --no-group-separator)
aria2c $(python3 ~/config/nix/packages/windows/get-latest-update.py --dotnet-url)
wget "https://raw.githubusercontent.com/abbodi1406/BatUtil/master/W10UI/W10UI.cmd"
cat > W10UI.ini << "EOF"
[W10UI-Configuration]
Target        =D:
Cleanup       =1
Delete_Source =1
EOF

# press "8", "2", "0" in W10UI
```
