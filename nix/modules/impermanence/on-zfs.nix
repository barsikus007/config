{ pkgs, ... }:
let
  # TODO: config: persistentDir
  persistentDir = "/persistent";
in
{
  imports = [
    ../../modules/impermanence
  ];

  fileSystems.${persistentDir}.neededForBoot = true;

  #? https://github.com/nix-community/impermanence/issues/320#issuecomment-4260870035
  boot.initrd.systemd.services.rollback-zroot = {
    description = "Rollback ZFS root to a pristine state";
    unitConfig.DefaultDependencies = false;
    # The script needs to run to completion before this service is done
    serviceConfig.Type = "oneshot";
    # This service is required for boot to succeed (requiredBy will produce kernel panic)
    wantedBy = [ "initrd.target" ];
    after = [ "zfs-import-zroot.service" ];
    # Should complete before any file systems are mounted
    before = [ "sysroot.mount" ];

    path = with pkgs; [ zfs ];
    script = "zfs rollback -r zroot/root@blank";
  };

  environment.persistence."${persistentDir}" = {
    directories = [
      "/etc/zfs/keys"
    ];
    files = [
      "/etc/zfs/zpool.cache" # ? https://nixos.org/manual/nixos/unstable/#sec-zfs-state
    ];
  };
}
