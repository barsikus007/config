{
  pkgs,
  inputs,
  config,
  ...
}:
{
  networking.hostName = "ROG14"; # Define your hostname

  environment.systemPackages = (
    import ../../shared/lists {
      inherit pkgs;
    }
    ++ import ../../shared/lists/test.nix {
      inherit pkgs;
    }
  );

  imports = [
    #? https://github.com/NixOS/nixos-hardware/blob/master/asus/zephyrus/ga401/default.nix
    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga401
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/hardware/fingerprint.nix
  ];

  boot = {
    #? Blazing fast https://xanmod.org/
    # kernelPackages = pkgs.linuxPackages_latest;
    kernelPackages = pkgs.linuxPackages_zen;
    # kernelPackages = pkgs.linuxPackages_xanmod_stable;

    # Use the systemd-boot EFI boot loader.
    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
        configurationLimit = 5;
        # rebootForBitlocker = true;
      };
      efi.canTouchEfiVariables = true;
    };

    # https://wiki.nixos.org/wiki/Plymouth
    plymouth.enable = true;

    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;

    #? https://wiki.nixos.org/wiki/NTFS
    supportedFilesystems = [ "ntfs" ];
  };

  hardware = {
    #? https://github.com/NixOS/nixos-hardware/issues/1450
    nvidia.dynamicBoost.enable = false;

    #! https://github.com/NixOS/nixpkgs/issues/429624#issuecomment-3261936923
    nvidia.package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "580.65.06";
      sha256_64bit = "sha256-BLEIZ69YXnZc+/3POe1fS9ESN1vrqwFy6qGHxqpQJP8=";
      openSha256 = "sha256-BKe6LQ1ZSrHUOSoV6UCksUE0+TIa0WcCHZv4lagfIgA=";
      settingsSha256 = "sha256-9PWmj9qG/Ms8Ol5vLQD3Dlhuw4iaFtVHNC0hSyMCU24=";
      usePersistenced = false;
    };

    bluetooth.enable = true;
  };

  services = {
    #? https://asus-linux.org/guides/nixos/
    supergfxd.enable = true;
    asusd = {
      enable = true;
      # package = pkgs.unstable.asusctl;
      #! https://gitlab.com/asus-linux/asusctl/-/issues/530#note_2101255275
      # enableUserService = true;
      #? https://asus-linux.org/manual/asusctl-manual/
      # TODO fanCurvesConfig = '''';
    };
  };

  # disable 4.2 GHz boost
  systemd.tmpfiles.rules = [
    "w /sys/devices/system/cpu/cpufreq/boost - - - - 0"
  ];
  # TODO: 25.11
  # boot.kernel.sysfs = {
  #   devices.system.cpu.cpufreq.boost = 0;
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
