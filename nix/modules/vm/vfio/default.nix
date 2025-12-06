{ inputs, ... }:
# https://wiki.nixos.org/wiki/PCI_passthrough
# https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF
# https://j-brn.github.io/nixos-vfio/options.html
# https://astrid.tech/2022/09/22/0/nixos-gpu-vfio #? VR and Hotplug; single for further research
# https://github.com/QaidVoid/Complete-Single-GPU-Passthrough
{
  imports = [
    inputs.nixos-vfio.nixosModules.vfio
  ];

  virtualisation.hugepages = {
    enable = true;
    defaultPageSize = "2M";
    pageSize = "2M";
    # https://wiki.archlinux.org/title/KVM#Enabling_huge_pages
    numPages = 4150; # 8G + smth
  };

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

  #region declarative domains XML
  #! lacks of sysinfo (for stealthing VM's smbios), numa (for memoryBacking hugepages (use memfd?)) setup
  # virtualisation.libvirtd.qemu.domains.declarative = true;
  virtualisation.libvirtd.qemu.domains.domains = {
    "win10".config = {
      memory = {
        memory = {
          value = 8;
          unit = "G";
        };

        disableBallooning = true;
        useHugepages = true;
      };

      vcpu = {
        placement = "static";
        count = 12;
      };

      cputune = {
        vcpupins = builtins.genList (i: {
          vcpu = i;
          cpuset = [ (i + 4) ];
        }) 12;
      };

      cpu = {
        mode = "host-passthrough";
        topology = {
          sockets = 1;
          dies = 1;
          cores = 6;
          threads = 2;
        };
      };

      input = {
        virtioMouse = true;
        virtioKeyboard = true;
      };

      pciHostDevices = [
        # Nvidia RTX2060
        {
          sourceAddress = {
            bus = "0x01";
            slot = "0x00";
            function = 0;
          };
        }

        # Nvidia RTX2060 audio device
        {
          sourceAddress = {
            bus = "0x01";
            slot = "0x00";
            function = 1;
          };
        }

        # Nvidia RTX2060 USB
        {
          sourceAddress = {
            bus = "0x01";
            slot = "0x00";
            function = 2;
          };
        }

        # Nvidia RTX2060 Serial (Type-C)
        {
          sourceAddress = {
            bus = "0x01";
            slot = "0x00";
            function = 3;
          };
        }
      ];

      networkInterfaces = [ { sourceNetwork = "default"; } ];

      # TODO: unattend.iso;virtio.iso
      # cdroms = [];
      devicesExtraXml = ''
        <disk type='file' device='disk'>
          <driver name='qemu' type='qcow2'/>
          <source file='/var/lib/libvirt/images/win10.qcow2'/>
          <target dev='sda' bus='sata'/>
          <address type='drive' controller='0' bus='0' target='0' unit='0'/>
        </disk>

        <tpm model="tpm-crb">
          <backend type="emulator" version="2.0"/>
        </tpm>
      '';

      kvmfr = {
        device = "/dev/kvmfr0";
        size = "67108864"; # is 64M (for 2560x1440)
      };
    };
  };
  #? or
  /*
    virtualisation.libvirt.connections."qemu:///system".pools = [
      {
        # active = true;
        definition = inputs.nixVirt.lib.pool.writeXML {
          name = "default";
          uuid = "TODO";
          type = "dir";
          target = {
            path = "/var/lib/libvirt/images";
          };
        };
        volumes = [
          {
            present = false;
            definition = inputs.nixVirt.lib.volume.writeXML {
              name = "win10.qcow2";
              capacity = {
                count = 40;
                unit = "GiB";
              };
              target.format.type = "qcow2";
            };
          }
        ];
      }
    ];
    virtualisation.libvirt.connections."qemu:///system".domains = [
      {
        # active = true;
        definition =
          let
            baseXML = inputs.nixVirt.lib.domain.templates.windows {
              name = "win10";
              # uuid = "TODO";
              memory = {
                count = 8;
                unit = "GiB";
              };
              storage_vol = {
                pool = "default";
                volume = "win10.qcow2";
              };
              # install_vol = "TODO";
              virtio_net = true;
              virtio_video = true;
              virtio_drive = true;
              install_virtio = true;
            };
          in
          inputs.nixVirt.lib.domain.writeXML (
            baseXML
            // {
              devices = baseXML.devices // {
                disk = baseXML.devices.disk ++ [
                  # TODO: unattend.iso
                ];
                hostdev = builtins.genList (i: {
                  type = "pci";
                  managed = true;
                  source.address = {
                    bus = 1;
                    slot = 0;
                    function = i;
                  };
                }) 4;
              };
            }
          );
      }
    ];
  */
  #endregion declarative domains XML
}
