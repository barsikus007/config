{
  pkgs,
  config,
  inputs,
  username,
  ...
}:
#? ZFS pool was created manually on nvme0n1p4:
#?
#? echo -n "PASSPHRASE" > /tmp/secret.key && chmod 600 /tmp/secret.key
#? # remove -R /mnt
#? {
#?   grep "zpool create" $(nix build ./nix#nixosConfigurations.ROG14.config.system.build.diskoScript --print-out-paths) --after-context=4
#?   echo zroot /dev/disk/by-id/nvme-Force_MP510_210482470001292050F3-part4
#? }
#? zfs snapshot zroot/root@blank
#?
#? grep "zfs create" $(nix build ./nix#nixosConfigurations.ROG14.config.system.build.diskoScript --print-out-paths) --after-context=2
#? zfs change-key -o keylocation=prompt zroot
let
  #? https://wiki.archlinux.org/title/NTFS-3G#Linux_compatible_permissions
  ntfsUserMapping = pkgs.writeText "ntfs-usermapping" ''
    1000::S-1-5-21-2891596990-1220146427-2962973337-1001
    :100:S-1-5-21-2891596990-1220146427-2962973337-513
    ::S-1-5-21-2891596990-1220146427-2962973337-10000
  '';
in
{
  imports = [
    inputs.disko.nixosModules.disko
  ];

  disko.devices = {
    disk = {
      nvme = {
        device = "/dev/disk/by-id/nvme-Force_MP510_210482470001292050F3";
        destroy = false;
        content = {
          type = "gpt";
          # TODO
        };
      };
    };
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
          "usermapping=${ntfsUserMapping}"
        ];
      };
      "/run/media/${username}/System" = {
        fsType = "ntfs-3g";
        device = "/dev/disk/by-label/System";
        # device = "/dev/disk/by-uuid/01DCD272E968DAA0";
        mountOptions = [
          "rw"
          "usermapping=${ntfsUserMapping}"
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
          };
          "nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
          };
          "persistent" = {
            type = "zfs_fs";
            mountpoint = "/persistent";
          };
        };
      };
    };
  };
}
