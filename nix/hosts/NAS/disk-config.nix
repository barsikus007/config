{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
  ];

  disko.devices = {
    disk = {
      #? SSD
      nvme = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-SAMSUNG_MZVLB512HAJQ-00000_S3W8NA0M675571";
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
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
      # exos_master = {
      #   type = "disk";
      #   device = "/dev/disk/by-id/ata-ST8000NM017B-2TJ103_WWZ4N3WQ";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       zfs = {
      #         size = "100%";
      #         content = {
      #           type = "zfs";
      #           pool = "tank";
      #         };
      #       };
      #     };
      #   };
      # };
      # exos_mirror = {
      #   type = "disk";
      #   device = "/dev/disk/by-id/ata-ST8000NM0105-1VS112_ZA1NGMKF";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       zfs = {
      #         size = "100%";
      #         content = {
      #           type = "zfs";
      #           pool = "tank";
      #         };
      #       };
      #     };
      #   };
      # };
    };
    zpool = {
      "tank" = {
        type = "zpool";
        options = {
          ashift = "12";
        };
        rootFsOptions = {
          mountpoint = "/tank";
          compression = "zstd";
          normalization = "formC";
          atime = "off";
          xattr = "sa";
          acltype = "posixacl";
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "file:///etc/zfs/keys/tank.key";
        };

        datasets = {
          "apps" = {
            type = "zfs_fs";
            mountpoint = "/tank/apps";
            options."com.sun:auto-snapshot" = "true";
          };
          "docker" = {
            type = "zfs_fs";
            mountpoint = "/tank/docker";
            options."com.sun:auto-snapshot" = "false";
          };
          "storage" = {
            type = "zfs_fs";
            mountpoint = "/tank/storage";
            options."com.sun:auto-snapshot" = "true";
          };
        };
      };

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

          #? README MORE: https://wiki.archlinux.org/title/ZFS#Swap_volume
          "swap" = {
            type = "zfs_volume";
            size = "16G";
            content = {
              type = "swap";
              randomEncryption = true;
            };
            options = {
              volblocksize = "4096";
              compression = "zle";
              logbias = "throughput";
              sync = "always";
              primarycache = "metadata";
              secondarycache = "none";
              "com.sun:auto-snapshot" = "false";
            };
          };
        };
      };

      # tank = {
      #   type = "zpool";
      #   mode = "mirror";
      #   options = {
      #     ashift = "12";
      #   };
      #   rootFsOptions = {
      #     compression = "zstd";
      #     canmount = "off";
      #     # Шифрование
      #     encryption = "aes-256-gcm";
      #     keyformat = "passphrase";
      #     keylocation = "file:///etc/zfs/keys/tank_simple.key";
      #     normalization = "formC";
      #   };

      #   datasets = {
      #     storage = {
      #       type = "zfs_fs";
      #       mountpoint = "/tank/storage";
      #       options."com.sun:auto-snapshot" = "true";
      #     };
      #     apps = {
      #       type = "zfs_fs";
      #       mountpoint = "/tank/apps";
      #       options."com.sun:auto-snapshot" = "true";
      #     };
      #     docker = {
      #       type = "zfs_fs";
      #       mountpoint = "/tank/docker";
      #       options."com.sun:auto-snapshot" = "false";
      #     };
      #   };
      # };
    };
  };
}
