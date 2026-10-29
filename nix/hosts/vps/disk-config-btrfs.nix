{ lib, inputs, ... }:

let
  partitions =
    (import ./disk-config.nix { inherit lib inputs; })
    .disko.devices.disk.disk1.content.partitions;
in
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
          inherit (partitions) boot esp;
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "--force" ];
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "@persistent" = {
                  mountpoint = "/persistent";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "@swap" = {
                  mountpoint = "/swap";
                  swap.swapfile.size = lib.mkDefault "1G";
                };
              };
            };
          };
        };
      };
    };
  };

  fileSystems."/persistent".neededForBoot = true;
}
