{ config, pkgs, ... }:
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
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # https://wiki.nixos.org/wiki/AMD_GPU#System_Hang_with_Vega_Graphics_(and_select_GPUs)
    ../../packages/fixes/amd-fix.nix
    ../../modules/gui/plasma.nix
  ];

  time.hardwareClockInLocalTime = true; # cause windows
  boot = {
    # Blazing fast https://xanmod.org/
    kernelPackages = pkgs.linuxPackages_xanmod_stable;

    # Use the systemd-boot EFI boot loader.
    loader = {
      # timeout = 3;
      systemd-boot = {
        enable = true;
        editor = false;
        configurationLimit = 5;
        # https://search.nixos.org/options?channel=24.11&show=boot.loader.systemd-boot.rebootForBitlocker
        rebootForBitlocker = false;
        extraEntries = {
          "fedora.conf" = ''
            title Fedora's grub
            efi /efi/fedora/shimx64.efi
            sort-key z_fedora
          '';
        };
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
  };

  hardware = {
    # https://discourse.nixos.org/t/nvidia-565-77-wont-work-in-kernel-6-13/59234/10
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "570.86.16"; # use new 570 drivers
        sha256_64bit = "sha256-RWPqS7ZUJH9JEAWlfHLGdqrNlavhaR1xMyzs8lJhy9U=";
        openSha256 = "sha256-DuVNA63+pJ8IB7Tw2gM4HbwlOh1bcDg2AN2mbEU9VPE=";
        settingsSha256 = "sha256-9rtqh64TyhDF5fFAYiWl3oDHzKJqyOW3abpcf2iNRT8=";
        usePersistenced = false;
      };
      # https://github.com/NixOS/nixos-hardware/issues/1450
      dynamicBoost.enable = false;
    };

    bluetooth.enable = true;
  };

  # https://asus-linux.org/guides/nixos/
  services.supergfxd.enable = true;
  services = {
    asusd = {
      enable = true;
      package = pkgs.unstable.asusctl;
      #! https://gitlab.com/asus-linux/asusctl/-/issues/530#note_2101255275
      # enableUserService = true;
      #? https://asus-linux.org/manual/asusctl-manual/
      # TODO fanCurvesConfig = '''';
    };
  };

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  # TODO nekoray fixes https://t.me/ru_nixos/300840
  networking.firewall.checkReversePath = false;

  # List services that you want to enable:

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
