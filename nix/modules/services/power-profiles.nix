{
  lib,
  pkgs,
  config,
  ...
}:
#? bind system tweaks to power-profiles-daemon profiles instead of raw AC/DC state
#? so noctalia / XF86Launch4 / powerprofilesctl and udev all go through one place
let
  inherit (config.services) asusd;

  cpupower = lib.getExe config.boot.kernelPackages.cpupower;
  asusctl = lib.getExe' pkgs.asusctl "asusctl";
  ppdctl = lib.getExe' config.services.power-profiles-daemon.package "powerprofilesctl";
  gdbus = lib.getExe' pkgs.glib "gdbus";
  sed = lib.getExe pkgs.gnused;

  #? enable/disable anime powersave animation, asus-only
  anime = state: lib.optionalString asusd.enable "${asusctl} anime --enable-powersave-anim ${state}";

  applyProfile = pkgs.writeShellScript "apply-power-profile" /* shell */ ''
    case "''${1:-}" in
      performance)
        ${cpupower} frequency-set -g performance
        ${anime "true"}
        ;;
      balanced)
        ${cpupower} frequency-set -g ${config.powerManagement.cpuFreqGovernor}
        ${anime "true"}
        ;;
      power-saver)
        ${cpupower} frequency-set -g powersave
        ${anime "false"}
        ;;
      *)
        echo "unknown power profile: ''${1:-}" >&2
        exit 1
        ;;
    esac
  '';
in
{
  #? follow ActiveProfile on the system bus and apply tweaks on every change
  systemd.services.power-profile-hook = {
    description = "Apply system tweaks on power profile change";
    wantedBy = [ "multi-user.target" ];
    after = [
      "power-profiles-daemon.service"
    ]
    ++ lib.optional asusd.enable "asusd.service";
    wants = [ "power-profiles-daemon.service" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = 2;
    };
    script = /* shell */ ''
      #? dbus signals only fire on change, so sync once at startup
      ${applyProfile} "$(${ppdctl} get)" || true

      #? --object-path filters out the duplicate legacy net.hadess interface
      ${gdbus} monitor --system \
        --dest org.freedesktop.UPower.PowerProfiles \
        --object-path /org/freedesktop/UPower/PowerProfiles \
        | ${sed} --unbuffered -n "s/.*'ActiveProfile': <'\([a-z-]*\)'>.*/\1/p" \
        | while read -r profile; do
            ${applyProfile} "$profile" || true
          done
    '';
  };

  #? pick profile by AC state: on boot (wantedBy) and on plug/unplug (udev)
  systemd.services.power-profile-select = {
    description = "Select power profile based on AC state";
    wantedBy = [ "multi-user.target" ];
    after = [ "power-profile-hook.service" ];
    serviceConfig.Type = "oneshot";
    script = /* shell */ ''
      online=0
      for ps in /sys/class/power_supply/*; do
        [ "$(cat "$ps/type" 2>/dev/null)" = "Mains" ] || continue
        [ "$(cat "$ps/online" 2>/dev/null)" = "1" ] && online=1
      done

      if [ "$online" = "1" ]; then
        ${ppdctl} set performance
      else
        ${ppdctl} set power-saver
      fi
    '';
  };

  #! only "Mains" has meaningful `online`; "Battery" matches the mouse and fires on every percent tick
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", RUN+="${config.systemd.package}/bin/systemctl --no-block restart power-profile-select.service"
  '';
}
