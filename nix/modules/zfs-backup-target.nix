{
  lib,
  pkgs,
  config,
  username,
  ...
}:
let
  # TODO: backupSourceHosts
  backupSourceHost = "ROG14";
in
{
  #? syncoid "WARNING: mbuffer not available on target" fix
  environment.systemPackages = with pkgs; [ mbuffer ];

  #? with default `true` it tries to unlock recieved backups
  boot.zfs.requestEncryptionCredentials = lib.attrNames (
    lib.filterAttrs (
      _: pool: (pool.rootFsOptions.encryption or null) != null
    ) config.disko.devices.zpool
  );

  systemd.services.zfs-recv-setup = {
    description = "Delegate dataset perms to ${username}";
    wantedBy = [ "multi-user.target" ];
    after = [ "zfs-import.target" ];
    wants = [ "zfs-import.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [ config.boot.zfs.package ];
    # TODO: tank/backups/${backupSourceHost} is shared with disko
    script = ''
      set -euo pipefail

      zfs allow -u ${username} \
        create,mount,mountpoint,receive,destroy,rollback,bookmark,hold,send,compression,canmount,encryption,keyformat,keylocation,change-key \
        tank/backups/${backupSourceHost}
    '';
  };

  services.sanoid.datasets."tank/backups/${backupSourceHost}/persistent".use_template = [
    "default_backup"
  ];
}
