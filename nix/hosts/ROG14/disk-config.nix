{
  config,
  inputs,
  username,
  ...
}:
#? Disks is NOT managed by disko — nvme0n1 has NTFS partitions (Data, System) that must be preserved.
#? ZFS pool was created manually on nvme0n1p4:
#?
#?   echo -n "PASSPHRASE" > /tmp/secret.key && chmod 600 /tmp/secret.key
#?   zpool create -f \
#?     -o ashift=12 -o autotrim=on \
#?     -O mountpoint=none -O compression=zstd -O atime=off \
#?     -O acltype=posixacl -O xattr=sa \
#?     -O encryption=aes-256-gcm -O keyformat=passphrase \
#?     -O keylocation=file:///tmp/secret.key \
#?     zroot \
#?     /dev/disk/by-id/nvme-Force_MP510_210482470001292050F3_1-part4
#?
#?   zfs create -o mountpoint=/ -o com.sun:auto-snapshot=false zroot/root
#?   zfs snapshot zroot/root@blank
#?   zfs create -o mountpoint=/nix -o com.sun:auto-snapshot=false zroot/nix
#?   zfs create -o mountpoint=/persistent -o com.sun:auto-snapshot=true  zroot/persistent
#?   zfs change-key -o keylocation=prompt zroot
{
  imports = [
    inputs.disko.nixosModules.disko
  ];

  disko.devices = {
    nodev = {
      "/boot" = {
        fsType = "vfat";
        device = "/dev/disk/by-uuid/5099-6DA0";
        mountOptions = [
          "umask=0077"
        ];
      };
      "/run/media/${username}/Data" = {
        fsType = "ntfs-3g";
        device = "/dev/disk/by-label/Data";
        # device = "/dev/disk/by-uuid/01DC4611808524F0";
        mountOptions = [
          "rw"
          "uid=1000"
          "gid=100"
        ];
      };
      "/run/media/${username}/System" = {
        fsType = "ntfs-3g";
        device = "/dev/disk/by-label/System";
        # device = "/dev/disk/by-uuid/01DCD272E968DAA0";
        mountOptions = [
          "rw"
          "uid=1000"
          "gid=100"
        ];
      };
      "/run/media/${username}/NAS" = {
        #? https://wiki.nixos.org/wiki/Samba#CIFS_mount_configuration
        #! sudo systemctl restart run-media-$USER-NAS.automount
        fsType = "cifs";
        # device = "//NAS.lan/storage";
        device = "//192.168.1.2/storage";
        mountOptions = [
          #? this section prevents hanging on network split
          "_netdev"
          "noauto"
          "x-systemd.automount"
          "x-systemd.device-timeout=5s"
          "x-systemd.mount-timeout=5s"
          "x-systemd.requires=network-online.target"

          #? https://man7.org/linux/man-pages/man8/mount.cifs.8.html
          "soft" # ? disable program locking if mount unaccessible
          "credentials=${config.sops.templates."smb-credentials".path}"
          "rw"
          "uid=1000"
          "gid=100"
          "noserverino"
        ];
      };
    };
    zpool = {
      "zroot" = {
        type = "zpool";
        options = {
          ashift = "12";
          autotrim = "on";
        };
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
          atime = "off";
          acltype = "posixacl";
          xattr = "sa";
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "file:///tmp/secret.key";
        };
        postCreateHook = "zfs change-key -o keylocation=prompt zroot";

        datasets = {
          "root" = {
            type = "zfs_fs";
            mountpoint = "/";
            postCreateHook = "zfs list -t snapshot | grep -q zroot/root@blank || zfs snapshot zroot/root@blank";
            options."com.sun:auto-snapshot" = "false";
          };
          "nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options."com.sun:auto-snapshot" = "false";
          };
          "persistent" = {
            type = "zfs_fs";
            mountpoint = "/persistent";
            options."com.sun:auto-snapshot" = "true";
          };
        };
      };
    };
  };
}
