{
  lib,
  inputs,
  username,
  ...
}:
#? nix attrset mirrors https://libvirt.org/formatdomain.html: https://github.com/AshleyYakeley/NixVirt/blob/master/generate-xml/domain.nix
#! uuid, smbios serials and guest-side PCI addresses are the guest's hardware identity:
#! changing them makes windows re-enumerate devices and re-check activation
let
  name = "win10";
  uuid = "7c65d285-ed96-43d6-9bc6-52b781d1aff9";
  mac = "52:54:00:c4:f0:c0";

  #region tuning
  #? https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Performance_tuning
  memoryGiB = 8;
  #? https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#CPU_pinning
  hostThreads = 16; # R7 4800HS
  #? leave at least 4 threads to host
  vcpuCount = 12;
  #! don't forget to follow topology
  cputune = {
    vcpupin = builtins.genList (i: {
      vcpu = i;
      cpuset = toString (i + (hostThreads - vcpuCount));
    }) vcpuCount;
    emulatorpin.cpuset = "0-3";
  };
  cpu = {
    mode = "host-passthrough";
    #? https://libvirt.org/formatdomain.html#cpu-model-and-topology
    #? https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Improving_performance_on_AMD_CPUs
    migratable = false;
    topology = {
      sockets = 1;
      dies = 1;
      cores = 6;
      threads = 2;
    };
    feature = [
      {
        policy = "require";
        name = "topoext";
      }
    ];
    #? a single cell is what lets virtiofs share the guest memory
    #? the cell needs no memAccess: qemu gets share=true on ram-node0 from access.mode
    numa.cell = [
      {
        id = 0;
        cpus = "0-${toString (vcpuCount - 1)}";
        memory = memoryGiB;
        unit = "GiB";
      }
    ];
  };
  #endregion tuning

  #region spice
  #? https://looking-glass.io/docs/B7/install_libvirt/#keyboard-mouse-display-audio
  spiceTweaks = {
    graphics = [
      {
        type = "spice";
        autoport = true;
        listen = {
          type = "address";
          address = "127.0.0.1";
        };
      }
    ];
    video = [
      {
        model = {
          type = "vga";
        };
      }
    ];
    input = [
      {
        type = "mouse";
        bus = "virtio";
      }
      {
        type = "keyboard";
        bus = "virtio";
      }
    ];
    memballoon = [ { model = "none"; } ];
    #? https://looking-glass.io/docs/B7/install_libvirt/#clipboard-synchronization
    # TODO: possibly, added by default
    channel = [
      {
        type = "spicevmc";
        target = {
          type = "virtio";
          name = "com.redhat.spice.0";
        };
        address = {
          type = "virtio-serial";
          controller = 0;
          bus = 0;
          port = 1;
        };
      }
    ];
  };
  #endregion spice

  #region ivshmem
  #? 64M is enough for 2560x1440
  #? https://looking-glass.io/docs/B7/install_libvirt/#libvirt-determining-memory
  kvmfrDevice = "/dev/kvmfr0";
  kvmfrSize = 64 * 1024 * 1024;
  lookingGlass = {
    commandline = [
      { value = "-device"; }
      { value = "{'driver':'ivshmem-plain','id':'shmem0','memdev':'looking-glass'}"; }
      { value = "-object"; }
      {
        value = "{'qom-type':'memory-backend-file','id':'looking-glass','mem-path':'${kvmfrDevice}','size':${toString kvmfrSize},'share':true}";
      }
    ];
  };
  #endregion ivshmem

  #region virtiofs
  #? https://wiki.archlinux.org/title/Libvirt#Virtio-FS
  #? mount in guest: & "C:\Program Files\Virtio-Win\VioFS\virtiofs.exe" -t Data -m D:
  memoryBacking = {
    source.type = "memfd";
    access.mode = "shared";
    allocation.mode = "immediate";
  };
  virtiofsMount = bus: mountName: {
    type = "mount";
    accessmode = "passthrough";
    driver.type = "virtiofs";
    source.dir = "/run/media/${username}/${mountName}";
    target.dir = mountName;
    address = {
      type = "pci";
      domain = 0;
      inherit bus;
      slot = 0;
      function = 0;
    };
  };
  virtiofsMounts = [
    (virtiofsMount 11 "Data")
    (virtiofsMount 12 "System")
  ];
  #endregion virtiofs

  #region stealth
  #? https://libvirt.org/formatdomain.html#smbios-system-information
  sysinfo =
    let
      serial = "L6NRKD013371488";
    in
    {
      type = "smbios";
      bios.entry = [
        {
          name = "vendor";
          value = "American Megatrends Inc.";
        }
        {
          name = "version";
          value = "GA401IV.222";
        }
        {
          name = "date";
          value = "09/28/2023";
        }
      ];
      system.entry = [
        {
          name = "manufacturer";
          value = "ASUSTeK COMPUTER INC.";
        }
        {
          name = "product";
          value = "ROG Zephyrus G14 GA401IV_GA401IV";
        }
        {
          name = "version";
          value = "1.0       ";
        }
        {
          name = "serial";
          value = serial;
        }
        {
          name = "uuid";
          value = uuid;
        }
        {
          name = "sku";
          value = " ";
        }
        {
          name = "family";
          value = "ROG Zephyrus G14";
        }
      ];
      baseBoard.entry = [
        {
          name = "manufacturer";
          value = "ASUSTeK COMPUTER INC.";
        }
        {
          name = "product";
          value = "GA401IV";
        }
        {
          name = "version";
          value = "1.0       ";
        }
        {
          name = "serial";
          value = "J706MC1337";
        }
        {
          name = "asset";
          value = "ATN12345678901234567";
        }
        {
          name = "location";
          value = "MIDDLE              ";
        }
      ];
      chassis.entry = [
        {
          name = "manufacturer";
          value = "ASUSTeK COMPUTER INC.";
        }
        {
          name = "version";
          value = "1.0       ";
        }
        {
          name = "serial";
          value = serial;
        }
        {
          name = "asset";
          value = "No Asset Tag";
        }
        {
          name = "sku";
          value = "NA";
        }
      ];
    };
  #endregion stealth

  #region base
  base = inputs.nixvirt.lib.domain.templates.windows {
    inherit name uuid;
    memory = {
      count = memoryGiB;
      unit = "GiB";
    };
    vcpu = {
      count = vcpuCount;
    };
    nvram_path = "/var/lib/libvirt/qemu/nvram/${name}_VARS.fd";
  };

  nvidiaFunctions = 4;

  pcieRootPorts = builtins.genList (
    n:
    let
      index = n + 1;
      function = lib.mod n 8;
    in
    {
      type = "pci";
      inherit index;
      model = "pcie-root-port";
      target = {
        chassis = index;
        port = 15 + index;
        model.name = "pcie-root-port";
      };
      address = {
        type = "pci";
        domain = 0;
        bus = 0;
        slot = if index <= 8 then 2 else 3;
        inherit function;
        multifunction = if function == 0 then true else null;
      };
    }
  ) 15;
  #endregion base
in
lib.recursiveUpdate base {
  currentMemory = {
    count = memoryGiB;
    unit = "GiB";
  };

  inherit
    sysinfo
    memoryBacking
    cputune
    cpu
    ;

  os = {
    boot = null;
    firmware = "efi";
    machine = "pc-q35-10.1";
    loader = {
      readonly = true;
      secure = true;
      type = "pflash";
      path = "/run/libvirt/nix-ovmf/edk2-x86_64-secure-code.fd";
    };
    nvram = {
      template = "/run/libvirt/nix-ovmf/edk2-i386-vars.fd";
      templateFormat = "raw";
      format = "raw";
      path = "/var/lib/libvirt/qemu/nvram/${name}_VARS.fd";
    };
    #? https://astrid.tech/2022/09/22/0/nixos-gpu-vfio/#:~:text=Anti-Anti-Cheat%20Aktion
    smbios.mode = "sysinfo";
  };

  features = {
    vmport.state = false;
    #? required by secure boot (loader secure="yes")
    smm.state = true;
    hyperv = {
      #? breaks stealth: reveals KVM hypervisor string to guest anti-cheats
      vendor_id = null;
      #? only relevant for live migration between different TSC hosts
      reenlightenment = null;

      #? useful enlightenments inherited from template:
      # reset = { state = true; }; # MSR-based guest reboot
      # stimer.direct = { state = true; }; # direct APIC interrupt for timers instead of SynIC queue
    };
  };

  devices = {
    emulator = "/run/libvirt/nix-emulators/qemu-system-x86_64";

    disk = [
      {
        type = "block";
        device = "disk";
        driver = {
          name = "qemu";
          type = "raw";
          cache = "none";
          io = "native";
          discard = "unmap";
        };
        source.dev = "/dev/zvol/zroot/vms/${name}";
        target = {
          dev = "vda";
          bus = "virtio";
        };
        boot.order = 1;
        address = {
          type = "pci";
          domain = 0;
          bus = 13;
          slot = 0;
          function = 0;
        };
      }
    ];

    controller = [
      {
        type = "usb";
        index = 0;
        model = "qemu-xhci";
        ports = 15;
        address = {
          type = "pci";
          domain = 0;
          bus = 2;
          slot = 0;
          function = 0;
        };
      }
      {
        type = "pci";
        index = 0;
        model = "pcie-root";
      }
      {
        type = "pci";
        index = 16;
        model = "pcie-to-pci-bridge";
        target.model.name = "pcie-pci-bridge";
        address = {
          type = "pci";
          domain = 0;
          bus = 10;
          slot = 0;
          function = 0;
        };
      }
      {
        type = "sata";
        index = 0;
        address = {
          type = "pci";
          domain = 0;
          bus = 0;
          slot = 31;
          function = 2;
        };
      }
      {
        type = "virtio-serial";
        index = 0;
        address = {
          type = "pci";
          domain = 0;
          bus = 3;
          slot = 0;
          function = 0;
        };
      }
    ]
    ++ pcieRootPorts;

    filesystem = virtiofsMounts;

    interface = [
      {
        type = "network";
        mac.address = mac;
        source.network = "default";
        #? https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Virtio_network
        model.type = "virtio";
        address = {
          type = "pci";
          domain = 0;
          bus = 1;
          slot = 0;
          function = 0;
        };
      }
    ];

    inherit (spiceTweaks)
      graphics
      video
      input
      memballoon
      channel
      ;

    hostdev =
      #? whole iommu group of the dgpu, see virtualisation.vfio.devices in ./default.nix
      builtins.genList (function: {
        mode = "subsystem";
        type = "pci";
        managed = true;
        source.address = {
          domain = 0;
          bus = 1;
          slot = 0;
          inherit function;
        };
        address = {
          type = "pci";
          domain = 0;
          bus = 5 + function;
          slot = 0;
          function = 0;
        };
      }) nvidiaFunctions
      ++ [
        #? 0x20d1:0x7008, schema takes ids as ints and libvirt parses them base-prefixed
        {
          mode = "subsystem";
          type = "usb";
          managed = true;
          source = {
            startupPolicy = "optional";
            vendor.id = 8401;
            product.id = 28680;
          };
          address = {
            type = "usb";
            bus = 0;
            port = 1;
          };
        }
      ];
  };

  qemu-commandline.arg = lookingGlass.commandline;
}
