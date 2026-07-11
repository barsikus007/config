{
  lib,
  pkgs,
  config,
  username,
  ...
}:
#! vibecoded shitscript which checks size of pending backup
let
  nasSshHost = "NAS";

  #? notify the desktop BEFORE a push when it's unusually big (normal hourly ~<400 MB)
  largeSendThresholdBytes = 2 * 1024 * 1024 * 1024; # ? 2 GiB

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

    echo "Forcing backup push to ${nasSshHost}..."
    sudo ${config.systemd.package}/bin/systemctl start syncoid-zroot-persistent.service
    exec ${config.systemd.package}/bin/journalctl -fu syncoid-zroot-persistent.service
  '';

  #? runs as ExecStartPre, so it fires before syncoid streams anything. We can't
  #? hook syncoid's own estimate (Type=simple → ExecStartPost fires before the
  #? send, ExecStopPost only after it), so replicate it: ask the NAS for its
  #? newest snapshot = the incremental base, then `zfs send -nP` a dry-run to
  #? size the raw stream (-w matches sendOptions). On a big push, notify-send.
  #! `-`-prefixed in the unit, so any failure here never blocks the backup
  notifyLargeSend = pkgs.writeShellScript "syncoid-notify-large" /* shell */ ''
    set -euo pipefail

    zfs=${config.boot.zfs.package}/bin/zfs
    dataset=zroot/persistent
    target=tank/backups/ROG14/persistent

    #? only meaningful inside a live graphical session
    bus="/run/user/$(${pkgs.coreutils}/bin/id -u)/bus"
    [ -S "$bus" ] || exit 0

    #? newest local snapshot = what this run will push up to (ascending + tail
    #? avoids the SIGPIPE that `sort -S | head` would trip under pipefail)
    newest=$("$zfs" list -H -d1 -t snapshot -o name -s creation "$dataset" \
      | ${pkgs.coreutils}/bin/tail -n1)
    [ -n "$newest" ] || exit 0

    #? what the NAS already has → the common base for the incremental
    tgt=$(${pkgs.coreutils}/bin/timeout 15 ${pkgs.openssh}/bin/ssh -o BatchMode=yes \
      admin@${nasSshHost} -- zfs list -H -d1 -t snapshot -o name -s creation "$target" \
      2>/dev/null | ${pkgs.coreutils}/bin/tail -n1 || true)
    #? no base (empty target / ssh hiccup): skip rather than mis-size a "full" send
    [ -n "$tgt" ] || exit 0
    common="$dataset@''${tgt##*@}"
    #? already in sync → nothing to send
    [ "$common" != "$newest" ] || exit 0

    #? dry-run the exact stream syncoid will push; `size <bytes>` is the estimate
    bytes=$("$zfs" send -nPw -I "$common" "$newest" 2>/dev/null \
      | ${lib.getExe pkgs.gawk} '/^size/ { print $2 }')
    [ -n "''${bytes:-}" ] || exit 0
    [ "$bytes" -ge ${toString largeSendThresholdBytes} ] || exit 0

    size=$(${pkgs.coreutils}/bin/numfmt --to=iec --suffix=B "$bytes")
    DBUS_SESSION_BUS_ADDRESS="unix:path=$bus" \
      ${pkgs.libnotify}/bin/notify-send --app-name=Syncoid --urgency=normal \
      "Large ZFS backup to ${nasSshHost}" "zroot/persistent: ~$size, sending..."
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
    #? big-send notifier, BEFORE the push; `-` = ignore_errors so it never
    #? blocks the backup. Merges with upstream's zfs-allow ExecStartPre and runs
    #? after it (unitOption list concat preserves definition order)
    ExecStartPre = [ "-${notifyLargeSend}" ];
  };

  #? catch up a tick that was skipped while offline, once back online
  systemd.timers."syncoid-zroot-persistent".timerConfig.Persistent = true;

  environment.systemPackages = [ nasBackup ];
}
