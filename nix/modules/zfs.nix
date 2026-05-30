{
  nixpkgs.overlays = [
    (_: prev: { fastfetch = prev.fastfetch.override { zfsSupport = true; }; })
  ];

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
        autoprune = true;
        frequently = 4 * 2;
        hourly = 24 * 2;
        daily = 7 * 2;
        weekly = 4 * 2;
        monthly = 12 * 2;
      };
    };
  };
}
