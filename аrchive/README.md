# [Archive](../README.md)

`а` in folder name is cyrillic letter

## [Ubuntu](./ubuntu.md)

## [Fedora on GA401IV](./fedora.md)

## [Linux on Rock3A](./rock3a.md)

## [OpenWrt on Xiaomi AX3600](./ax3600.md)

## android

### DriveDroid fix on Pixel 7 Pro (better use [module](https://github.com/overzero-git/DriveDroid-fix-Magisk-module))

```shell
curl -sL https://gist.github.com/barsikus007/2e44999712cdb074a1c9a9803cad7b8f/raw/ce0bd0e58403d4cbf44a0297fa994a6e1c3fdd7e/fixdd > ~/fixdd && sudo cp fixdd /data/adb/service.d/fixdd && sudo chmod +x /data/adb/service.d/fixdd
```

#### [local script](./fixdd.sh)

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
