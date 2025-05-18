{ pkgs, ... }:
{
  services.syncthing.enable = true;
  services.syncthing.tray.enable = true;
  # services.syncthing.tray.pachage = TODO?;
  # home.packages = with pkgs; [ syncthingtray-qt6 ];
}
