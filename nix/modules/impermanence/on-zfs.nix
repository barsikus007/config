{ config, ... }:
{
  imports = [
    ../../modules/impermanence
  ];

  #? https://github.com/nix-community/impermanence/issues/320#issuecomment-4260870035
  boot.initrd.systemd.services.rollback-zroot = {
    description = "Rollback ZFS root to a pristine state";
    unitConfig.DefaultDependencies = false;
    # the script needs to run to completion before this service is done
    serviceConfig.Type = "oneshot";
    # this service is required for boot to succeed (requiredBy will produce kernel panic)
    wantedBy = [ "initrd.target" ];
    after = [ "zfs-import-zroot.service" ];
    # should complete before any file systems are mounted
    before = [ "sysroot.mount" ];

    path = [ config.boot.zfs.package ];
    script = "zfs rollback -r zroot/root@blank";
  };

  environment.persistence.${config.custom.persist.dir} = {
    directories = [
      "/etc/zfs/keys"
    ];
    files = [
      "/etc/zfs/zpool.cache" # ? https://nixos.org/manual/nixos/unstable/#sec-zfs-state
    ];
  };
}
