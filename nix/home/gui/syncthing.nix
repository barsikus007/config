{ pkgs, ... }:
{
  services.syncthing.enable = true;
  services.syncthing.tray.enable = true;
  services.syncthing.tray.package = pkgs.syncthingtray;
}
