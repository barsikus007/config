{
  nixpkgs.overlays = [
    (_: prev: { fastfetch = prev.fastfetch.override { zfsSupport = true; }; })
  ];

  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot.enable = true;
}
