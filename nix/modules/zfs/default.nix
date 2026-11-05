{ lib, config, ... }:
let
  zfsFileSystems = lib.filterAttrs (_: fs: fs.fsType == "zfs") config.fileSystems;
  getPool = fs: lib.head (lib.splitString "/" fs.device);
  rootPool =
    if (config.fileSystems ? "/") && config.fileSystems."/".fsType == "zfs" then
      getPool config.fileSystems."/"
    else
      null;
  dataPools = lib.unique (
    lib.filter (p: p != rootPool) (
      (map getPool (lib.attrValues zfsFileSystems)) ++ (config.boot.zfs.extraPools or [ ])
    )
  );
  importServices = lib.genAttrs (map (p: "zfs-import-${p}") dataPools) (_: {
    restartIfChanged = false;
    stopIfChanged = false;
  });
in
{
  nixpkgs.overlays = [
    (_final: prev: { fastfetch = prev.fastfetch.override { zfsSupport = true; }; })
  ];
  virtualisation.docker.storageDriver = lib.mkDefault "zfs";

  # TODO: unstable: system.stateVersion = "26.11"
  boot.zfs.forceImportRoot = lib.mkDefault false;

  services.zfs.autoScrub.enable = true;
  services.sanoid = {
    enable = true;
    interval = "*:0/15";
    templates = {
      default = {
        autosnap = true;
        autoprune = true;
        frequently = 4;
        hourly = 24;
        daily = 7;
        weekly = 4;
        monthly = 12;
      };
      default_backup = {
        autosnap = false;
        autoprune = true;
        frequently = 4 * 2;
        hourly = 24 * 2;
        daily = 7 * 2;
        weekly = 4 * 2;
        monthly = 12 * 2;
      };
    };
  };

  #? prevent switch-to-configuration from unmounting data pools during switch
  systemd.services = importServices // {
    zfs-mount.restartIfChanged = false;
    zfs-mount.stopIfChanged = false;
    zfs-share.restartIfChanged = false;
    zfs-share.stopIfChanged = false;
  };
}
