{ inputs, ... }:
#! example to create a bios compatible gpt partition
#? https://github.com/nix-community/nixos-anywhere-examples/blob/7f945ff0ae676c0eb77360b892add91328dd1f17/disk-config.nix
{
  imports = [
    inputs.disko.nixosModules.disko
  ];

  disko.devices = {
    disk.disk1 = {
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "1M";
            type = "EF02";
          };
          esp = {
            name = "ESP";
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              #! https://github.com/nix-community/disko/issues/739
              preCreateHook = "sleep 3";
            };
          };
          root = {
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "pool";
            };
          };
        };
      };
    };
    lvm_vg.pool = {
      type = "lvm_vg";
      lvs.root = {
        size = "100%FREE";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/";
          mountOptions = [
            "defaults"
          ];
        };
      };
    };
  };
}
