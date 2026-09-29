{
  lib,
  inputs,
  username,
  ...
}:
#? https://wiki.nixos.org/wiki/PCI_passthrough
#? https://j-brn.github.io/nixos-vfio/options.html
{
  imports = [
    inputs.nixos-vfio.nixosModules.vfio
    inputs.nixvirt.nixosModules.default
  ];

  virtualisation.hugepages = {
    #? grep --ignore-case huge /proc/meminfo
    #? sync && sudo sysctl --write vm.drop_caches=3 && sudo sysctl --write vm.compact_memory=1 && sudo sysctl --write vm.nr_hugepages=4400
    # enable = true;
    defaultPageSize = "2M";
    pageSize = "2M";
    # https://wiki.archlinux.org/title/KVM#Enabling_huge_pages
    numPages = 4400; # ? (8G / 2M) + 10%
  };

  virtualisation.libvirtd = {
    deviceACL = [
      "/dev/ptmx" # ? for pty
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
      #? lspci -nn | grep --ignore-case nvidia
      "10de:1f12" # VGA
      "10de:10f9" # Audio
      "10de:1ada" # USB
      "10de:1adb" # Serial (Type-C)
    ];
    blacklistNvidia = true;
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

  virtualisation.libvirt = {
    # TODO: PR: nixvirt: update nixpkgs due to python eol
    enable = true;
    connections."qemu:///system".domains = [
      {
        definition = inputs.nixvirt.lib.domain.writeXML (
          import ./win10.nix { inherit inputs lib username; }
        );
        #? never power-cycle a running guest on activation
        restart = false;
      }
    ];
  };
}
