{ inputs, ... }:
# https://wiki.nixos.org/wiki/PCI_passthrough
# https://j-brn.github.io/nixos-vfio/options.html
# https://github.com/devusb/nix-config/blob/fcf2d44464f1a6bf8d38f208e12d8bf31bdf2354/hosts/tomservo/vfio.nix
# https://alexbakker.me/post/nixos-pci-passthrough-qemu-vfio.html
# https://astrid.tech/2022/09/22/0/nixos-gpu-vfio
{
  imports = [
    inputs.nixos-vfio.nixosModules.vfio
  ];

  virtualisation.libvirtd = {
    deviceACL = [
      "/dev/kvmfr0"
      # "/dev/kvm"
      # # "/dev/kvmfr1"
      # # "/dev/kvmfr2"
      # "/dev/shm/looking-glass"
      # # "/dev/shm/scream"
      # "/dev/vfio/vfio"

      # "/dev/null"
      # "/dev/full"
      # "/dev/zero"
      # "/dev/random"
      # "/dev/urandom"
      # "/dev/ptmx"
      # "/dev/rtc"
      # "/dev/hpet"
      # # "/dev/kqemu"
    ];
  };

  virtualisation.vfio = {
    enable = true;
    # TODO: isAsus: device specific
    #? Kernel auto-detects if IOMMU is enabled in BIOS on AMD, but module needs this setting
    IOMMUType = "amd";
    devices = [
      #? you need to pass all devices in group? cause otherwise "Please ensure all devices within the iommu_group are bound to their vfio bus driver."
      #? https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Ensuring_that_the_groups_are_valid
      #? lspci -nn | grep -i nvidia
      "10de:1f12" # VGA
      "10de:10f9" # Audio
      "10de:1ada" # USB
      "10de:1adb" # Serial (Type-C)
    ];
  };

  virtualisation.kvmfr = {
    enable = true;
    devices = [
      {
        # https://looking-glass.io/docs/B7/install_libvirt/#libvirt-determining-memory
        size = 64; # 2560x1440
        permissions = {
          group = "libvirtd";
          mode = "0660";
        };
      }
    ];
  };
}
