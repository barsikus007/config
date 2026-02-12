{
  lib,
  pkgs,
  inputs,
  config,
  username,
  ...
}:
{
  networking.hostName = "ROG14";

  environment.systemPackages = (
    import ../../shared/lists {
      inherit pkgs;
    }
    ++ import ../../shared/lists/extra.nix {
      inherit pkgs;
    }
    ++ import ../../shared/lists/test.nix {
      inherit pkgs;
    }
  );

  imports = [
    #? https://github.com/NixOS/nixos-hardware/blob/master/asus/zephyrus/ga401/default.nix
    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga401
    ./hardware-configuration.nix
    ../../modules/hardware/fingerprint.nix
    ../../modules/hardware/wifi-unlimited.nix
  ];
  home-manager.users.${username} = ./home.nix;

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
        configurationLimit = 5;
        # TODO: hackintosh (and/or refind)
        extraEntries = {
          "macos.conf" = ''
            title macOS
            efi /efi/OC/OpenCore.efi
          '';
        };
        #? sort-key macos
      };
      efi.canTouchEfiVariables = true;
    };

    kernelParams = [
      #? NixOS param which enables root-shell when stage 1 fails
      "boot.shell_on_fail"
    ];

    #? https://wiki.nixos.org/wiki/NTFS
    supportedFilesystems = [ "ntfs" ];
  };

  hardware = {
    amdgpu.opencl.enable = true;

    #! https://github.com/NixOS/nixos-hardware/issues/1450
    nvidia.dynamicBoost.enable = false;
    #? if GPU apps fails after suspend
    # nvidia.powerManagement.enable = true;
    #? finer GPU power management
    nvidia.powerManagement.finegrained = true;

    bluetooth.enable = true;
  };

  #? https://asus-linux.org/guides/nixos/
  services = {
    asusd = {
      enable = true;
      #! https://gitlab.com/asus-linux/asusctl/-/issues/530#note_2101255275
      # enableUserService = true;
    };
  };

  # TODO: laptop generic
  #! after reboot with/out powersupply it is set to perfomance/schedutil: cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
  powerManagement.cpuFreqGovernor = "schedutil";
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${lib.getExe config.boot.kernelPackages.cpupower} frequency-set -g schedutil"
    ACTION=="add|change", SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${lib.getExe config.boot.kernelPackages.cpupower} frequency-set -g performance"
  '';
  #? disable 4.2 GHz boost
  systemd.tmpfiles.rules = [
    "w /sys/devices/system/cpu/cpufreq/boost - - - - 0"
  ];

  #? https://nixos.org/manual/nixos/unstable/release-notes
  system.stateVersion = "26.05";
}
