{ lib, inputs, ... }:
let
  partitions =
    (import ./disk-config-btrfs.nix { inherit lib inputs; })
    .disko.devices.disk.disk1.content.partitions;
in
{
  imports = [
    inputs.disko.nixosModules.disko
  ];

  #? bake keyfile into systemd initrd for automatic headless unlock
  # boot.initrd.systemd.contents."/keyfile.bin".text = defaultKey;
  # boot.initrd.luks.devices.crypted.keyFile = "/keyfile.bin";

  disko.devices = {
    disk.disk1 = {
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          inherit (partitions) boot esp;
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypted";
              passwordFile = "/tmp/crypt.key";
              settings.allowDiscards = true;
              inherit (partitions.root) content;
            };
          };
        };
      };
    };
  };

  fileSystems."/persistent".neededForBoot = true;
}
