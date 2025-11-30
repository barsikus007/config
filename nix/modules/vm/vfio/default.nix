{ pkgs, inputs, ... }:
# https://wiki.nixos.org/wiki/PCI_passthrough
# https://j-brn.github.io/nixos-vfio/options.html
# https://github.com/j-brn/nixos-vfio/issues/69
# https://github.com/devusb/nix-config/blob/fcf2d44464f1a6bf8d38f208e12d8bf31bdf2354/hosts/tomservo/vfio.nix
# https://alexbakker.me/post/nixos-pci-passthrough-qemu-vfio.html
# https://astrid.tech/2022/09/22/0/nixos-gpu-vfio
#? single for further research
# https://github.com/QaidVoid/Complete-Single-GPU-Passthrough
{
  imports = [
    inputs.nixos-vfio.nixosModules.vfio
  ];

  # TODO: https://j-brn.github.io/nixos-vfio/options.html#virtualisationhugepagesenable
  # TODO: https://j-brn.github.io/nixos-vfio/options.html#virtualisationlibvirtdqemudomainsdeclarative
  # TODO: virtualisation.libvirtd.qemu.domains.domains."win10".

  virtualisation.libvirtd = {
    deviceACL = [
      "/dev/ptmx" # for pty
      "/dev/kvm"
      "/dev/kvmfr0"
      # "/dev/vfio/vfio"

      # "/dev/null"
      # "/dev/full"
      # "/dev/zero"
      # "/dev/random"
      # "/dev/urandom"
      # "/dev/rtc"
      # "/dev/hpet"
    ];
  };

  virtualisation.vfio = {
    enable = true;
    # TODO: isAsus: device specific
    #? Kernel auto-detects if IOMMU is enabled in BIOS on AMD, but module needs this setting
    # TODO: PR: amd_iommu doesn't accept an on value, it never has, read the kernel arguments documentation. The default is already on. looking-glass discord: https://discord.com/channels/804108879436316733/1080928977922838548/1349027466227748895
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
        size = 64;
        # TODO: PR: https://github.com/j-brn/nixos-vfio/issues/85
        # resolution = {
        #   width = 2560;
        #   height = 1440;
        #   pixelFormat = "rgb24";
        # };
        permissions = {
          group = "libvirtd";
          mode = "0660";
        };
      }
    ];
  };
  #? isn't needed with working kvmfr
  # systemd.tmpfiles.rules = [
  #   "f /dev/shm/looking-glass 0660 ${username} qemu-libvirtd -"
  # ];

  environment.defaultPackages = with pkgs; [
    # looking-glass-client
    (looking-glass-client.overrideAttrs {
      version = "B7-g3efe47ffb2";

      src = fetchFromGitHub {
        owner = "gnif";
        repo = "LookingGlass";
        rev = "3efe47ffb21ca96ed46b2a9342b3cee4df553987";
        hash = "sha256-kIS5JuEu2DnZdB+kRQ6jUR6pcR0hYiJLjZK3witvJcM=";
        fetchSubmodules = true;
      };
    })
  ];
}
