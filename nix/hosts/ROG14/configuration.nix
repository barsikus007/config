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
    # TODO: unstable: pinned this way until next LTS release
    ../../modules/zfs/compatible-kernel.nix
    ../../modules/zfs
    ../../modules/zfs/backup-source.nix

    ../../modules/hardware/fingerprint.nix
    ../../modules/hardware/wifi-unlimited.nix
    ../../modules/services/power-profiles.nix
  ];
  home-manager.users.${username} = ./home.nix;

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
  services.lact =
    let
      ids = import ./ids.nix;
    in
    {
      enable = true;
      settings = {
        version = 7;
        daemon = {
          log_level = "info";
          disable_nvapi = false;
          admin_group = "wheel";
        };
        apply_settings_timer = 5;
        gpus.${ids.gpu.discrete.lactId} = {
          fan_control_enabled = false;
          nvidia_gpu_vf_curve = builtins.fromJSON (builtins.readFile ./gpu-vf-curve-undervolt.json);
        };
      };
    };

  #? https://opengamingcollective.github.io/asusctl/distributions/nixos.html
  services.asusd = {
    enable = true;
    #? let power-profiles-daemon manage profiles; asusd only applies fan curves
    asusdConfig.text = /* rust */ ''
      (
          platform_profile_linked_epp: false,
          change_platform_profile_on_battery: false,
          change_platform_profile_on_ac: false,
          //? defaults
          charge_control_end_threshold: 100,
          base_charge_control_end_threshold: 100,
          disable_nvidia_powerd_on_battery: true,
          ac_command: "",
          bat_command: "",
          platform_profile_on_battery: Quiet,
          platform_profile_on_ac: Performance,
          profile_quiet_epp: Power,
          profile_balanced_epp: BalancePower,
          profile_custom_epp: Performance,
          profile_performance_epp: Performance,
          ac_profile_tunings: {},
          dc_profile_tunings: {},
          armoury_settings: {},
      )
    '';
    #? keyboard backlight permanently off across all power states
    auraConfigs."1866".text = /* rust */ ''
      (
          brightness: Off,
          enabled: (
              states: [
                  (
                      zone: Keyboard,
                      boot: false,
                      awake: false,
                      sleep: false,
                      shutdown: false,
                  ),
              ],
          ),
          //? defaults
          config_name: "aura_1866.ron",
          current_mode: Static,
          builtins: {
              Static: (
                  mode: Static,
                  zone: r#None,
                  colour1: (
                      r: 166,
                      g: 0,
                      b: 0,
                  ),
                  colour2: (
                      r: 0,
                      g: 0,
                      b: 0,
                  ),
                  speed: Med,
                  direction: Right,
              ),
              Breathe: (
                  mode: Breathe,
                  zone: r#None,
                  colour1: (
                      r: 166,
                      g: 0,
                      b: 0,
                  ),
                  colour2: (
                      r: 0,
                      g: 0,
                      b: 0,
                  ),
                  speed: Med,
                  direction: Right,
              ),
              Pulse: (
                  mode: Pulse,
                  zone: r#None,
                  colour1: (
                      r: 166,
                      g: 0,
                      b: 0,
                  ),
                  colour2: (
                      r: 0,
                      g: 0,
                      b: 0,
                  ),
                  speed: Med,
                  direction: Right,
              ),
          },
          multizone_on: false,
      )
    '';
    #! airplane mode xD
    #? p=$(asusctl profile get | awk '/Active profile/ {print $3}') && asusctl fan-curve --mod-profile $p --fan cpu --data "20c:100%,44c:100%,47c:100%,50c:100%,53c:100%,56c:100%,60c:100%,98c:100%" && asusctl fan-curve --mod-profile $p --fan gpu --data "20c:100%,44c:100%,47c:100%,50c:100%,53c:100%,56c:100%,60c:100%,98c:100%" && asusctl fan-curve --mod-profile $p --enable-fan-curves true
    #! land an airplane
    #? asusctl fan-curve --default
    fanCurvesConfig.text = /* rust */ ''
      (
          profiles: (
              balanced: [
                  (
                      fan: CPU,
                      // pwm: (28, 41, 48, 59, 71, 102, 120, 135),
                      pwm: (0, 0, 20, 59, 71, 102, 120, 135),
                      temp: (20, 48, 51, 54, 57, 61, 65, 98),
                      enabled: true,
                  ),
                  (
                      fan: GPU,
                      // pwm: (35, 53, 63, 71, 86, 112, 130, 155),
                      pwm: (0, 0, 20, 71, 86, 112, 130, 155),
                      temp: (20, 48, 51, 54, 57, 61, 65, 98),
                      enabled: true,
                  ),
              ],
              performance: [
                  (
                      fan: CPU,
                      // pwm: (45, 58, 71, 89, 102, 114, 135, 158),
                      pwm: (0, 30, 71, 89, 102, 114, 135, 158),
                      temp: (20, 50, 55, 60, 65, 70, 75, 98),
                      enabled: true,
                  ),
                  (
                      fan: GPU,
                      // pwm: (63, 71, 86, 102, 112, 124, 155, 178),
                      pwm: (0, 30, 86, 102, 112, 124, 155, 178),
                      temp: (20, 50, 55, 60, 65, 70, 75, 98),
                      enabled: true,
                  ),
              ],
              quiet: [
                  (
                      fan: CPU,
                      // pwm: (17, 28, 35, 40, 48, 58, 71, 89),
                      pwm: (0, 0, 0, 0, 20, 40, 71, 89),
                      temp: (20, 44, 47, 50, 53, 56, 60, 98),
                      enabled: true,
                  ),
                  (
                      fan: GPU,
                      // pwm: (28, 35, 45, 53, 63, 71, 86, 102),
                      pwm: (0, 0, 0, 0, 20, 40, 86, 102),
                      temp: (20, 44, 47, 50, 53, 56, 60, 98),
                      enabled: true,
                  ),
              ],
          ),
      )
    '';
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
    #? https://opengamingcollective.github.io/asusctl/faq/keyboard.html#can-i-re-map-the-arrow-keys
    evdev:name:*:dmi:bvn*:bvr*:bd*:svnASUS*:pn*:*
      KEYBOARD_KEY_ff3100c4=pageup    # Fn+Up
      KEYBOARD_KEY_ff3100c5=pagedown  # Fn+Down
  '';
  #? others in https://github.com/NixOS/nixos-hardware/blob/41c6b421bdc301b2624486e11905c9af7b8ec68e/asus/zephyrus/ga401iv/default.nix#L34
}
