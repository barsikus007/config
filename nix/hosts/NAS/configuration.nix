{
  lib,
  pkgs,
  username,
  ...
}:
{
  #? ZFS requires networking.hostId to be set
  networking.hostId = "20260425";

  #? https://nixos.org/manual/nixos/unstable/release-notes
  system.stateVersion = "26.05";
  networking.hostName = "NAS";
  time.timeZone = "Europe/Moscow";

  environment.systemPackages = (import ../../shared/lists { inherit pkgs; });

  imports = [
    ./..
    ./hardware-configuration.nix
    ./disk-config.nix
    ./impermanence.nix

    ../../modules/zfs-kernel.nix
    # ../../modules/cachyos-kernel.nix
    #! read warning inside module below
    ../../modules/ssh-initrd.nix
  ];
  home-manager.users.${username} = ./home.nix;

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  networking.useDHCP = true;
  networking.nftables.enable = true;

  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot.enable = true;

  hardware.bluetooth.enable = true;

  #? https://wiki.nixos.org/wiki/AMD_GPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.amdgpu.opencl.enable = true;
  #? https://wiki.nixos.org/wiki/AMD_GPU#Radeon_500_series_(aka_Polaris)
  environment.variables.ROC_ENABLE_PRE_VEGA = "1";

  #? https://wiki.nixos.org/wiki/OpenRGB
  hardware.i2c.enable = true;
  services.hardware.openrgb.enable = true;
  #? https://gitlab.com/OpenRGBDevelopers/OpenRGB-Wiki/-/blob/stable/User-Documentation/Frequently-Asked-Questions.md#can-i-set-up-openrgb-as-a-systemd-service
  systemd.services.openrgb-turn-off = {
    description = "Turn off the lights via OpenRGB";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe pkgs.openrgb} --color 000000";
      # User = "nobody";
      Group = "i2c";
    };
    wantedBy = [ "multi-user.target" ];
  };

  #? https://wiki.nixos.org/wiki/Linux_kernel#Enable_SysRq
  boot.kernel.sysctl."kernel.sysrq" = 1;
}
