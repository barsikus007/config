{
  imports = [
    ./wayland.nix
    ./fonts.nix
  ];

  #? https://wiki.archlinux.org/title/Java#Java_applications_cannot_open_external_links
  # also for gio mount
  services.gvfs.enable = true;
}
