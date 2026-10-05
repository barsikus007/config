{
  lib,
  pkgs,
  config,
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

  environment.systemPackages = builtins.concatLists (
    map (pkgsList: import pkgsList { inherit pkgs; }) [
      ../../shared/lists
      ../../shared/lists/10_extra.nix
      ../../shared/lists/99_test.nix
    ]
  );

  #! modules here are bound to specific hardware features (including disks)
  imports = [
    ../laptop.nix
    # TODO: PR: file for whole 2020th ga401, not just iv; https://github.com/NixOS/nixos-hardware/issues/1450
    #? https://github.com/NixOS/nixos-hardware/blob/master/asus/zephyrus/ga401iv/default.nix
    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga401iv
    ./hardware-configuration.nix
    ./disk-config.nix
    ./impermanence.nix
    ./sops.nix

    ../../modules/systemd-boot.nix
    ../../modules/zfs/lts-kernel.nix
    ../../modules/zfs
    ../../modules/zfs/backup-source.nix

    ../../modules/hardware/fingerprint.nix
    ../../modules/hardware/wifi-unlimited.nix
    ../../modules/services/power-profiles.nix
  ];
  home-manager.users.${username} = ./home.nix;
  # TODO: unstable: pinned this way until next LTS release
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_7_2;

  services.sanoid.datasets = lib.genAttrs [ "zroot/persistent" ] (_: {
    use_template = [ "default" ];
  });

  boot.kernelParams = [
    #? NixOS param which enables root-shell when stage 1 fails
    "boot.shell_on_fail"
    #? cap GTT and TTM buffer allocations to prevent GPU memory bloat from starving RAM
    "ttm.pages_limit=2621440" # fourth (10 GiB) of RAM
  ];

  #? build aarch64 derivations locally, e.g. the phone guest in hosts/android
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  hardware = {
    amdgpu.opencl.enable = true;

    #? if GPU apps fails after suspend
    # nvidia.powerManagement.enable = true;
    #? finer GPU power management
    nvidia.powerManagement.finegrained = true;
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

  custom.powerProfiles.actions.system =
    let
      cpupower = lib.getExe config.boot.kernelPackages.cpupower;
      asusctl = lib.getExe' pkgs.asusctl "asusctl";
      #? enable/disable anime powersave animation, asus-only
      asusctlAnime = state: "${asusctl} anime --enable-powersave-anim ${state}";
    in
    {
      performance = /* shell */ ''
        ${cpupower} frequency-set --governor performance
        ${asusctlAnime "true"}
      '';
      balanced = /* shell */ ''
        ${cpupower} frequency-set --governor ${config.powerManagement.cpuFreqGovernor}
        ${asusctlAnime "true"}
      '';
      powerSaver = /* shell */ ''
        ${cpupower} frequency-set --governor powersave
        ${asusctlAnime "false"}
      '';
    };

  #? asusd USB handle to AniMe (ITE 193b) dies after resume; hid-generic reclaims iface 0
  #? keyboard backlight also comes back on and needs asusd up
  powerManagement.resumeCommands =
    let
      systemctl = lib.getExe' config.systemd.package "systemctl";
      asusctl = lib.getExe' pkgs.asusctl "asusctl";
    in
    /* shell */ ''
      ${systemctl} restart asusd.service
      for _ in 1 2 3 4 5; do
        ${asusctl} leds set off && sleep 0.5
      done
    '';

  #? default is "mem standby freeze", so a failed suspend falls through to s2idle,
  #? which this firmware cannot do (FADT has no low-power S0) and amdgpu rejects
  #? after a deep attempt anyway (Unsupported suspend state 1)
  #? the fallback can only burn another 20s of kernel freezer timeout, never succeed
  systemd.sleep.settings.Sleep.SuspendState = "mem";

  #? disable device specific 4.2 GHz boost
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
}
