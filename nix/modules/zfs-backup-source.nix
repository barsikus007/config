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
  };

  #? catch up a tick that was skipped while offline, once back online
  systemd.timers."syncoid-zroot-persistent".timerConfig.Persistent = true;

  environment.systemPackages = [ nasBackup ];
}
