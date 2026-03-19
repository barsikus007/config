{
  lib,
  pkgs,
  inputs,
  config,
  username,
  ...
}:
{
  #? https://nixos.org/manual/nixos/unstable/release-notes
  system.stateVersion = "26.05";
  networking.hostName = "ROG14";

  environment.systemPackages = (
    import ../../shared/lists { inherit pkgs; }
    ++ import ../../shared/lists/extra.nix { inherit pkgs; }
    ++ import ../../shared/lists/test.nix { inherit pkgs; }
  );

  imports = [
    ./..
    # TODO: PR: file for whole 2020th ga401, not just iv; https://github.com/NixOS/nixos-hardware/issues/1450
    #? https://github.com/NixOS/nixos-hardware/blob/master/asus/zephyrus/ga401iv/default.nix
    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga401iv
    ./hardware-configuration.nix
    ./impermanence.nix
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
    ACTION=="add|change", SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${lib.getExe config.boot.kernelPackages.cpupower} frequency-set -g powersave"
    ACTION=="add|change", SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${lib.getExe config.boot.kernelPackages.cpupower} frequency-set -g performance"
  '';
  #? disable 4.2 GHz boost
  systemd.tmpfiles.rules = [
    "w /sys/devices/system/cpu/cpufreq/boost - - - - 0"
  ];

  #? use Fn+Arrows buttons as Home/End/PgUp/PgDown
  services.udev.extraHwdb = ''
    #? https://asus-linux.org/faq/keyboard/remap-arrow-keys/
    evdev:name:*:dmi:bvn*:bvr*:bd*:svnASUS*:pn*:*
      KEYBOARD_KEY_ff3100c4=pageup    # Fn+Up
      KEYBOARD_KEY_ff3100c5=pagedown  # Fn+Down
  '';
  #? others in https://github.com/NixOS/nixos-hardware/blob/41c6b421bdc301b2624486e11905c9af7b8ec68e/asus/zephyrus/ga401iv/default.nix#L34

  #? https://wiki.nixos.org/wiki/Linux_kernel#Enable_SysRq
  boot.kernel.sysctl."kernel.sysrq" = 1;
}
