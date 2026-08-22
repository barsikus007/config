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
#?   echo /dev/disk/by-id/nvme-Force_MP510_210482470001292050F3-part4
#? }
#? zfs snapshot zroot/root@blank
#?
#? grep "zfs create" $(nix build ./nix#nixosConfigurations.ROG14.config.system.build.diskoScript --print-out-paths) --after-context=2
#? zfs change-key -o keylocation=prompt zroot
let
  user = config.users.users.${username};
  uid = toString user.uid;
  gid = toString config.users.groups.${user.group}.gid;

  #? https://wiki.archlinux.org/title/NTFS-3G#Linux_compatible_permissions
  sid = "S-1-5-21-2891596990-1220146427-2962973337";
  ntfsUserMapping = pkgs.writeText "ntfs-usermapping" ''
    ${uid}::${sid}-1001
    :${gid}:${sid}-513
    ::${sid}-10000
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
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            # TODO
            # zfs = {
            #   size = "100%";
            #   content = {
            #     type = "zfs";
            #     pool = "zroot";
            #   };
            # };
          };
        };
      };
    };
    nodev = {
      "/run/media/${username}/Data" = {
        fsType = "ntfs-3g";
        device = "/dev/disk/by-label/Data";
        mountOptions = [
          "rw"
          "usermapping=${ntfsUserMapping}"
        ];
      };
      "/run/media/${username}/System" = {
        fsType = "ntfs-3g";
        device = "/dev/disk/by-label/System";
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
          "x-systemd.automount"
          #! irresponsible mount hangs caller for timeout (default 90s)
          "x-systemd.mount-timeout=5s"
          #! helps with fails on boot
          "x-systemd.requires=network-online.target"
          #? soft unmount for share after timeout (disabled by default)
          "x-systemd.idle-timeout=120"

          #? https://man7.org/linux/man-pages/man8/mount.cifs.8.html
          #! cifs declares a server dead only after 3*echo_interval, so the 60s
          #! default means 180s of blocked kernel freezer on every suspend attempt
          #! 10 cuts that to 30s, still over the 20s freezer timeout
          "echo_interval=10"
          "credentials=${config.sops.templates."smb-credentials".path}"
          "uid=${uid}"
          "gid=${gid}"
        ];
      };
      # TODO: fallback until big ZFS based /tank
      "/tank/storage" = {
        fsType = "none";
        device = "/run/media/${username}/Data";
        mountOptions = [
          "bind"
          #? without it systemd may bind the still-empty mountpoint
          "x-systemd.requires-mounts-for=/run/media/${username}/Data"
          "nofail"
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
            postCreateHook = "zfs list -t snapshot | grep --quiet zroot/root@blank || zfs snapshot zroot/root@blank";
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
