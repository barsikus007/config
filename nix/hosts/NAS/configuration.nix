{
  lib,
  pkgs,
  username,
  ...
}:
{
  #? ZFS requires networking.hostId to be set
  networking.hostId = "20260425";

  networking.hostName = "NAS";
  time.timeZone = "Europe/Moscow";

  environment.systemPackages =
    (import ../../shared/lists { inherit pkgs; })
    ++ (import ../../shared/lists/12_python.nix { inherit pkgs; });

  imports = [
    ../extra.nix
    ./hardware-configuration.nix
    ./disk-config.nix
    ./impermanence.nix
    ./sops.nix

    ../../modules/systemd-boot.nix
    ../../modules/zfs-lts-kernel.nix
    # ../../modules/cachyos-kernel.nix
    ../../modules/zfs.nix
    ../../modules/zfs-backup-target.nix

    #! read warning inside module below
    ../../modules/ssh-initrd.nix
  ];
  home-manager.users.${username} = ./home.nix;

  services.sanoid.datasets = lib.genAttrs [ "tank/apps" "tank/storage" "zroot/persistent" ] (_: {
    use_template = [ "default" ];
  });

  networking.useDHCP = true;
  networking.nftables.enable = true;
  networking.dhcpcd.denyInterfaces = [
    "veth*"
    "br-*"
    "docker*"
  ];

  hardware.bluetooth.enable = true;

  #? https://wiki.nixos.org/wiki/AMD_GPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.amdgpu.opencl.enable = true;
  #? https://wiki.nixos.org/wiki/AMD_GPU#Radeon_500_series_(aka_Polaris)
  environment.variables.ROC_ENABLE_PRE_VEGA = "1";

  hardware.i2c.enable = true;
  boot.kernelModules = [ "i2c-piix4" ]; # ? from `services.hardware.openrgb.enable`
  systemd.services.openrgb-turn-off = {
    description = "Turn off the lights via OpenRGB";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe pkgs.openrgb} --noautoconnect --color 000000";
    };
    wantedBy = [ "multi-user.target" ];
  };

  #? https://wiki.nixos.org/wiki/Linux_kernel#Enable_SysRq
  boot.kernel.sysctl."kernel.sysrq" = true;
}
