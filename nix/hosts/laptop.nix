{ lib, pkgs, ... }:
let
  umount = lib.getExe' pkgs.util-linux "umount";
  powerprofilesctl = lib.getExe pkgs.power-profiles-daemon;
  grep = lib.getExe pkgs.gnugrep;
in
{
  imports = [
    ./extra.nix

    ../modules/cool-boot.nix
  ];

  hardware.bluetooth.enable = true;

  systemd.settings.Manager.DefaultTimeoutStopSec = "20s";
  systemd.user.settings.Manager.DefaultTimeoutStopSec = "15s";
  #? upstream user@.service overrides DefaultTimeoutStopSec with 120s
  systemd.services."user@".serviceConfig.TimeoutStopSec = "15s";

  #? default governor, same for the balanced profile
  powerManagement.cpuFreqGovernor = "schedutil";
  #? stop mount.cifs shares, which locks sleep process
  #! NM deauthenticates wifi in the same second logind announces the suspend, so a
  #! graceful SMB logoff has no link left and waits out x-systemd.mount-timeout,
  #! measured at 5s per suspend; --force aborts pending requests via
  #! cifs_umount_begin instead of waiting for the server
  #! selecting by type, not by path: an automount stacks autofs under the share,
  #! and umount of an already unmounted path would take the autofs trigger down
  #! || true is load-bearing: a failed ExecStart skips ExecStop of the same unit,
  #! where every resumeCommands lives
  powerManagement.powerDownCommands = ''
    ${umount} --all --types cifs --force || true

    #? disable USB controllers wakeup so bluetooth/mouse packets cannot wake laptop in bag
    for xhc in XHC0 XHC1; do
      if ${grep} --quiet "^$xhc.*enabled" /proc/acpi/wakeup 2>/dev/null; then
        echo "$xhc" > /proc/acpi/wakeup
      fi
    done
  '';

  #? https://wiki.nixos.org/wiki/Linux_kernel#Enable_SysRq
  #? it have same security level as having force-reset power-button
  boot.kernel.sysctl."kernel.sysrq" = true;

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "powerprofilesctl-cycle" ''
      case "$(${powerprofilesctl} get 2>/dev/null)" in
        (power-saver)
          ${powerprofilesctl} set balanced
          ;;
        (balanced)
          ${powerprofilesctl} set performance
          ;;
        (*)
          ${powerprofilesctl} set power-saver
          ;;
      esac
    '')
  ];
}
