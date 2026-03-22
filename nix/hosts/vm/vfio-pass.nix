{
  pkgs,
  config,
  username,
  ...
}:
#? WIP: incomplete and messed as F
{
  virtualisation.vmVariant = {
    virtualisation = {
      qemu.options = [
        #? looking glass
        # "-object memory-backend-file,id=shmmem-lg,mem-path=/dev/kvmfr0,size=64M,share=yes"
        # "-device ivshmem-plain,memdev=shmmem-lg"

        "-device vfio-pci,host=01:00.0,x-vga=on"

        # "-mem-path /dev/hugepages"
        # "-mem-prealloc"
        #? sudo prlimit --memlock=unlimited:unlimited --pid $$ && ulimit -l
        #? prlimit --memlock=unlimited:unlimited ./result/bin/run-*-vm
      ];
    };
  };
  boot.extraModulePackages = with config.boot.kernelPackages; [ kvmfr ];
  environment.etc = {
    "modules-load.d/kvmfr.conf".text = ''
      kvmfr
    '';

    "modprobe.d/kvmfr.conf".text = ''
      options kvmfr static_size_mb=64
    '';
  };
  services.udev.extraRules = ''
    SUBSYSTEM=="kvmfr", GROUP="video", MODE="0660"
  '';

  environment.systemPackages =
    with pkgs;
    [
      (callPackage (builtins.fetchurl {
        url = "https://raw.githubusercontent.com/Yeshey/nixOS-Config/26723df921862360a3fa78e9066f7f681cba0b27/pkgs/looking-glass-host.nix";
        sha256 = "sha256-K3lCcm63bzBXuBKOj1hVadh8Fnmae5cy6uQ3SRtZ5pY=";
      }) { })

      gpu-screen-recorder
      gpu-screen-recorder-gtk
    ]
    ++ import ../../shared/lists { inherit pkgs; };
  users.users.${username}.extraGroups = [ "video" ];
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;
}
