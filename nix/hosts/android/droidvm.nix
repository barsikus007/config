{
  lib,
  config,
  inputs,
  username,
  modulesPath,
  ...
}:
{
  networking.hostName = "droidvm";

  imports = [
    inputs.disko.nixosModules.disko

    "${modulesPath}/profiles/qemu-guest.nix"
    ../../modules/ssh-secure.nix

    ../../modules/copy-flake.nix
  ];

  system.requiredKernelConfig = with config.lib.kernelConfig; [ (isYes "DMA_RESTRICTED_POOL") ];

  #! for easier VM use, insecure
  security.sudo.wheelNeedsPassword = lib.mkDefault false;
  services.getty.autologinUser = username;

  boot.loader.systemd-boot.enable = true;

  #! host pins the whole guest memory, ballooning and ksm have nobody to cooperate with
  hardware.ksm.enable = false;

  disko.devices.disk.disk1 = {
    #? DroidVM hands the guest a single virtio-blk disk
    device = lib.mkDefault "/dev/vda";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        esp = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
