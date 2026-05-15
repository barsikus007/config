{ inputs, ... }:
#? Disks is NOT managed by disko — nvme0n1 has NTFS partitions (Data, System) that must be preserved.
#? ZFS pool was created manually on nvme0n1p4:
#?
#?   echo -n "PASSPHRASE" > /tmp/secret.key && chmod 600 /tmp/secret.key
#?   zpool create -f \
#?     -o ashift=12 -o autotrim=on \
#?     -O mountpoint=none -O compression=zstd -O atime=off \
#?     -O xattr=sa -O acltype=posixacl \
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
    zpool = {
      zroot = {
        type = "zpool";
        options = {
          ashift = "12";
          autotrim = "on";
        };
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
          atime = "off";
          xattr = "sa";
          acltype = "posixacl";
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
