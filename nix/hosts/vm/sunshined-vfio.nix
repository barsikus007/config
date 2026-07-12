{
  lib,
  pkgs,
  config,
  ...
}:
#! no way desktop GPU passthrough on linux can be THAT cursed
#! my laptop's nvidia is hardcoded
{
  imports = [ ./sunshined.nix ];

  virtualisation.vmVariant.virtualisation = {
    #? headless: -nographic serial console + ssh(22222); emulated bochs VGA stays as early boot console
    graphics = false;
    qemu.options = [
      #? real host CPU, less overhead/jitter
      "-cpu host"
      #? pass the whole RTX2060 IOMMU group: VGA + HDMI audio (+.2/.3 usb/serial if needed)
      "-device vfio-pci,host=01:00.0,multifunction=on"
      "-device vfio-pci,host=01:00.1"
    ];
  };
  #! qemu-vm forces videoDrivers=["modesetting"] via mkVMOverride (prio 10) inside the vmVariant
  virtualisation.vmVariant.services.xserver.videoDrivers = lib.mkOverride 9 [ "nvidia" ];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;
  hardware.nvidia.modesetting.enable = true;
  #! capture hands Sunshine an nvidia DMABUF; without adapter_name it inits EGL on mesa (fd -1) -> black
  services.sunshine.settings = {
    encoder = "nvenc";
    adapter_name = "/dev/dri/renderD128"; # ? nvidia render node (pci-0000:00:09.0-render in guest)
  };

  #? DP-1 connector verified; if you change the GPU confirm the name via `ls /sys/class/drm` in the guest
  hardware.display = {
    #! edid-generator caps modeline names at 12 chars; WQHD@144 pclk <=655.35 MHz (EDID DTD 16bit*10kHz)
    edid.modelines = {
      "WQHD@144" = "626.69 2560 2608 2640 2720 1440 1443 1448 1600 -hsync +vsync";
      "FHD@60" = "148.50 1920 2008 2052 2200 1080 1084 1089 1125 +hsync +vsync";
    };
    #! module makes ONE mode per EDID; splice both into a single dual-DTD EDID so the compositor/Sunshine
    #! see BOTH: WQHD@144 = preferred (DTD1), FHD@60 = DTD2 over the name descriptor @byte 72
    edid.packages = [
      (pkgs.runCommand "edid-dp1-dual" { } ''
        mkdir -p "$out/lib/firmware/edid"
        ${pkgs.python3}/bin/python3 -c '
        import sys
        d, out = sys.argv[1], sys.argv[2]
        a = bytearray(open(d + "/WQHD@144.bin", "rb").read())
        b = open(d + "/FHD@60.bin", "rb").read()
        a[72:90] = b[54:72]            # desc2 (name) <- FHD@60 detailed timing
        a[127] = (-sum(a[:127])) % 256 # recompute EDID block checksum
        open(out + "/dp1-dual.bin", "wb").write(a)
        ' "${config.hardware.display.edid.modelines}/lib/firmware/edid" "$out/lib/firmware/edid"
      '')
    ];
    outputs."DP-1" = {
      edid = "dp1-dual.bin";
      mode = "e"; # ? force-enable the output (video=DP-1:e)
    };
  };
}
