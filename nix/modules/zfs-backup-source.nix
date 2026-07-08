{
  lib,
  pkgs,
  config,
  username,
  ...
}:
let
  nasSshHost = "NAS";

  #? ExecCondition: exit 0 → run; 1-254 → clean skip. timeout→124, refused→1: both skip
  #? /dev/tcp is a bash builtin
  #? `ssh -G NAS` resolves hostname/port from ssh_config without connecting
  nasReachable = pkgs.writeShellScript "nas-reachable" /* shell */ ''
    set -euo pipefail
    host= port=
    while read -r k v _; do
      case "$k" in
        hostname) host=$v ;;
        port)     port=$v ;;
      esac
    done < <(${pkgs.openssh}/bin/ssh -G ${nasSshHost})
    exec ${pkgs.coreutils}/bin/timeout 5 ${lib.getExe pkgs.bash} -c "echo > /dev/tcp/$host/$port"
  '';

  nasBackup = pkgs.writeShellScriptBin "nas-backup" /* shell */ ''
    set -euo pipefail
    probe() { ${nasReachable} 2>/dev/null; }

    if ! probe; then
      echo "${nasSshHost} unreachable - aborting." >&2
      exit 1
    fi

    echo "Forcing backup push to NAS…"
    sudo ${config.systemd.package}/bin/systemctl start syncoid-zroot-persistent.service
    exec ${config.systemd.package}/bin/journalctl -fu syncoid-zroot-persistent.service
  '';

  #? notify the desktop when a single push is unusually big (normal hourly ~<400 MB)
  largeSendThresholdMiB = 2 * 1024; #? 2 GiB

  #? syncoid logs one size estimate per send: "... (~ 357.9 MB):". After the unit
  #? stops we read that back from THIS invocation's journal and, on a big push,
  #? pop a notify-send. Must be ExecStopPost, not ExecStartPost: the unit is
  #? Type=simple, so ExecStartPost would fire before anything is actually sent
  notifyLargeSend = pkgs.writeShellScript "syncoid-notify-large" /* shell */ ''
    set -euo pipefail

    #? successful pushes only, and only when a live graphical session exists
    [ "''${SERVICE_RESULT:-}" = success ] || exit 0
    bus="/run/user/$(${pkgs.coreutils}/bin/id -u)/bus"
    [ -S "$bus" ] || exit 0

    #? syncoid's own estimate for this run, e.g. "2.3 GB"
    size=$(${config.systemd.package}/bin/journalctl \
        _SYSTEMD_INVOCATION_ID="''${INVOCATION_ID:-}" --output=cat 2>/dev/null \
      | ${pkgs.gnugrep}/bin/grep -oP '\(~ \K[0-9.]+ [KMGT]?B(?=\))' \
      | ${pkgs.coreutils}/bin/tail -n1)
    [ -n "$size" ] || exit 0

    #? syncoid steps are 1024-based but labelled KB/MB/GB; fold to MiB
    mib=$(echo "$size" | ${lib.getExe pkgs.gawk} '{
      f["B"] = 1 / 1048576; f["KB"] = 1 / 1024; f["MB"] = 1;
      f["GB"] = 1024; f["TB"] = 1048576;
      printf "%d", $1 * f[$2]
    }')
    [ "$mib" -ge ${toString largeSendThresholdMiB} ] || exit 0

    DBUS_SESSION_BUS_ADDRESS="unix:path=$bus" \
      ${pkgs.libnotify}/bin/notify-send --app-name=Syncoid --urgency=normal \
      "Крупный бэкап на NAS" "zroot/persistent: ~$size"
  '';
in
{
  services.syncoid = {
    enable = true;
    user = username;
    group = "users";
    # sshKey = "~/.ssh/id_ed25519";
    commonArgs = [
      "--no-sync-snap" # ? don't create own snapshots before syncing
      "--compress=none" # ? already compressed
    ];
    commands."zroot/persistent" = {
      # TODO: hardcoded
      target = "admin@${nasSshHost}:tank/backups/ROG14/persistent";
      #? raw send: NAS stores encrypted blocks
      sendOptions = "w";
      extraArgs = [
        "--sshoption=StrictHostKeyChecking=accept-new"
      ];
    };
  };
  systemd.services."syncoid-zroot-persistent".serviceConfig = {
    ExecCondition = "${nasReachable}";
    #? upstream masks `+/run/syncoid/<unit>` (= RootDirectory) so it can't be
    #? re-mounted into itself inside ExecStart's chroot. But systemd resolves
    #? WorkingDirectory= relative to RootDirectory for ALL Exec* lines (incl.
    #? ExecCondition / `-+`-ExecStopPost), even when RootDirectoryStartOnly=true
    #? skips the actual chroot(). The mount-ns is still built, so any chdir
    #? lands on the masked path → EACCES (no `+`) / ENOENT (with `+`, because
    #? the bind from StateDir isn't materialised yet at that stage). Drop the
    #? mask: we have no other binds to re-target into the chroot root
    InaccessiblePaths = lib.mkForce [ ];
    #? upstream's @system-service seccomp whitelist trips ssh (-G uses
    #? prlimit/@resources) and bash /dev/tcp
    SystemCallFilter = lib.mkForce [ ];
    #? need real ~/.ssh for `ssh -G`. ProtectHome=true mounts /home as noaccess
    #? /home becomes an empty tmpfs, .ssh bind layers on top
    ProtectHome = lib.mkForce "tmpfs";
    BindPaths = [ "/home/${username}/.ssh" ];
    #? ProtectHome=tmpfs also masks /run/user; re-expose it read-only so the
    #? notifier below can reach the session bus. /run/user always exists as a
    #? dir, so the bind never fails even with no session (notifier then skips)
    BindReadOnlyPaths = [ "/run/user" ];
    # TODO: vibecoded shitscript untested
    #? big-send notifier; `-` = ignore_errors so it never fails the backup.
    #? merges with upstream's zfs-unallow ExecStopPost (unitOption list concat)
    ExecStopPost = [ "-${notifyLargeSend}" ];
  };

  #? catch up a tick that was skipped while offline, once back online
  systemd.timers."syncoid-zroot-persistent".timerConfig.Persistent = true;

  environment.systemPackages = [ nasBackup ];
}
