{
  lib,
  pkgs,
  inputs,
  username,
  ...
}:
{
  #? ZFS requires networking.hostId to be set
  networking.hostId = "707c2d72";

  networking.hostName = "ROG14";

  custom = {
    isAsus = true;
    # blur.enable = true;
  };

  environment.systemPackages = (
    import ../../shared/lists { inherit pkgs; }
    ++ import ../../shared/lists/10_extra.nix { inherit pkgs; }
    ++ import ../../shared/lists/test.nix { inherit pkgs; }
  );

  #! modules here are bound to specific hardware features (including disks)
  imports = [
    ../extra.nix
    # TODO: PR: file for whole 2020th ga401, not just iv; https://github.com/NixOS/nixos-hardware/issues/1450
    #? https://github.com/NixOS/nixos-hardware/blob/master/asus/zephyrus/ga401iv/default.nix
    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga401iv
    ./hardware-configuration.nix
    ./disk-config.nix
    ./impermanence.nix
    ./sops.nix

    ../../modules/systemd-boot.nix
    # ../../modules/zfs-lts-kernel.nix
    ../../modules/cachyos-kernel.nix
    ../../modules/zfs.nix
    ../../modules/zfs-backup-source.nix

    ../../modules/hardware/fingerprint.nix
    ../../modules/hardware/wifi-unlimited.nix
    ../../modules/services/power-profiles.nix
  ];
  home-manager.users.${username} = ./home.nix;

  services.sanoid.datasets = lib.genAttrs [ "zroot/persistent" ] (_: {
    use_template = [ "default" ];
  });

  #? NixOS param which enables root-shell when stage 1 fails
  boot.kernelParams = [ "boot.shell_on_fail" ];

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
    #! I want to manage GPU myself
    supergfxd.enable = false;
    asusd = {
      enable = true;
      #! https://gitlab.com/asus-linux/asusctl/-/issues/530#note_2101255275
      # enableUserService = true;
    };
  };

  systemd.settings.Manager.DefaultTimeoutStopSec = "20s";
  systemd.user.settings.Manager.DefaultTimeoutStopSec = "15s";

  # TODO: laptop specific
  #? default governor, same for the balanced profile
  powerManagement.cpuFreqGovernor = "schedutil";

  #! vibecoded shitfix for keyboard backlight enabling after resume
  powerManagement.resumeCommands = ''
    for _ in 1 2 3 4 5; do
      ${lib.getExe' pkgs.asusctl "asusctl"} leds set off && sleep 0.5
    done
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
  #? it have same security level as having force-reset power-button
  boot.kernel.sysctl."kernel.sysrq" = true;
}
