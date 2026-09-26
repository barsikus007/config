# [аrchive](../README.md)

`а` in folder name is cyrillic letter

## [WSL](./wsl.md)

## [Ubuntu](./ubuntu.md)

## [Fedora on GA401IV](./fedora.md)

## [Linux on Rock3A](./rock3a.md)

## [OpenWrt on Xiaomi AX3600](./ax3600.md)

## [Raspberry Pi Zero W](./rpi-zero.md)

## Android

### [Mi TV Stick](./mitv.md)

### DriveDroid fix on Pixel 7 Pro (better use [module](https://github.com/overzero-git/DriveDroid-fix-Magisk-module))

```shell
curl -sL https://gist.github.com/barsikus007/2e44999712cdb074a1c9a9803cad7b8f/raw/ce0bd0e58403d4cbf44a0297fa994a6e1c3fdd7e/fixdd > ~/fixdd && sudo cp fixdd /data/adb/service.d/fixdd && sudo chmod +x /data/adb/service.d/fixdd
```

#### [local script](./fixdd.sh)

#### Pixel 7 Pro

- audio -- because no configuration and no difference
  - [ViPERFX RE](https://github.com/AndroidAudioMods/ViPERFX_RE)
  - [ViPER4Android Repackaged](https://github.com/programminghoch10/ViPER4AndroidRepackaged)
  - [?Dolby Atmos](https://gitlab.com/reiryuki-the-fixer/dolby-atmos-magic-revision-magisk-module)
  - [no root - wavelet](https://4pda.to/forum/index.php?showtopic=1039682&view=findpost&p=119899326)
- design and tweak mods -- because stock are the best
  - <https://github.com/Mahmud0808/Iconify>

## browser

### Chromium (Edge)

- [QuicKey](https://fwextensions.github.io/QuicKey/)
  - [C+Tab](https://fwextensions.github.io/QuicKey/ctrl-tab/)
    - <edge://extensions/shortcuts>
      - `chrome.developerPrivate.updateExtensionCommand({extensionId: "mcjciddpjefdpndgllejgcekmajmehnd", commandName: "30-toggle-recent-tabs", keybinding: "Ctrl+Tab"});`
      - or
      - `chrome.developerPrivate.updateExtensionCommand({extensionId: "mcjciddpjefdpndgllejgcekmajmehnd", commandName: "1-previous-tab", keybinding: "Ctrl+Tab"});chrome.developerPrivate.updateExtensionCommand({extensionId: "mcjciddpjefdpndgllejgcekmajmehnd", commandName: "2-next-tab", keybinding: "Ctrl+Shift+Tab"});`
- [PiP - Picture in Picture Plus](https://www.oinkandstuff.com/project/pip-picture-in-picture-plus/)

#### flags

- flag for faster downloads
  - <edge://flags/#enable-parallel-downloading> -> `Enabled`
- flag for QUIC protocol
  - <edge://flags/#enable-quic> -> `Enabled`
- flag for passkeys Bluetooth in <https://passkeys-debugger.io>
  - <edge://flags/#enable-experimental-web-platform-features> -> `Enabled`
- [fix for workspaces sidebar](https://answers.microsoft.com/en-us/microsoftedge/forum/all/how-to-remove-the-edge-sidebar-from-edge-workspace/bde1ede5-12a3-4f99-ac16-50b0f9878054?page=5)
  - <edge://flags/#edge-workspaces-skype-entry-point> -> `Enabled Hub chat icon`

## btrfs

```shell
sudo btrfs fi usage /

sudo btrfs balance start --full-balance --bg /
sudo btrfs balance status /

sudo btrfs scrub start /
sudo btrfs scrub status /
```

### backup to ZFS

```shell
sudo mkdir -p /btrfs_tmp && sudo mount /dev/disk/by-uuid/afb30336-18f3-4359-bebb-39c51e8f7b45 /btrfs_tmp
BACKUP_DATE=$(date +%Y-%m-%d)
sudo btrfs subvolume snapshot -r /btrfs_tmp/@persistent "/btrfs_tmp/@persistent-backup-$BACKUP_DATE"
sudo btrfs send "/btrfs_tmp/@persistent-backup-$BACKUP_DATE" | zstd | pv | ssh NAS "cat > /tank/storage/backups/hosts/desktops/ROG14/@persistent-backup-$BACKUP_DATE.btrfs.zst"

#? delete previous with
sudo btrfs subvolume delete /btrfs_tmp/...
```

### restore on ZFS

```shell
#? set target size of btrfs file system file
sudo truncate -s 160G /mnt/btrfs_restore.img
sudo mkfs.btrfs /mnt/btrfs_restore.img
sudo mkdir -p /mnt/btrfs_tmp
sudo mount /mnt/btrfs_restore.img /mnt/btrfs_tmp

BACKUP_DATE=2026-05-14
ssh NAS "cat /tank/storage/backups/hosts/desktops/ROG14/@persistent-backup-$BACKUP_DATE.btrfs.zst" | pv | zstdcat | sudo btrfs receive /mnt/btrfs_tmp

sudo rsync --verbose --archive --compress --partial --progress --mkpath --acls --xattrs --hard-links /mnt/btrfs_tmp/@persistent-backup-2026-05-14/ /mnt/persistent/

sudo btrfs subvolume delete /mnt/btrfs_tmp/@persistent-backup-2026-05-14
sudo umount /mnt/btrfs_tmp
sudo rm /mnt/btrfs_restore.img
```

## [proto](https://moonrepo.dev/proto)

### usage

```shell
# TODO https://moonrepo.dev/docs/proto/commands/completions
proto install go
# then clean ~/.bashrc
proto install node lts
proto install pnpm
proto install bun
# TODO proto install rust -- --profile minimal
```

### install

#### Linux

```shell
curl -fsSL https://moonrepo.dev/install/proto.sh | PROTO_INSTALL_DIR=$XDG_CONFIG_HOME/proto/bin bash -s -- --no-profile
rm -rf ~/.proto/
```

#### Windows

```powershell
$env:PROTO_INSTALL_DIR = "~\.config\proto\bin"
# irm https://moonrepo.dev/install/proto.ps1 | iex
& ([scriptblock]::Create((irm https://moonrepo.dev/install/proto.ps1))) --no-profile
Remove-Item -Recurse ~\.proto\
# TODO add proto to scoop
```

## other

- Docker Desktop extensions
  - Ddosify
  - Disk usage
- PyCharm
  - Settings Sync
  - Terminal | pwsh.exe -NoLogo
  - File > Settings > Appearance & Behavior > File Colors >> Non-Project Files -> Use in editor tabs
- YtMusic
  - adblocker
  - blur-nav-bar
  - lyrics-genius
  - navigation
  - picture-in-picture
  - precise-volume
  - shortcuts
  - sponsorblock
  - video-toggle
