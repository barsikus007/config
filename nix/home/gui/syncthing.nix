{ pkgs, ... }:
{
  services.syncthing.enable = true;
  services.syncthing.tray.enable = true;
  # TODO: unstable 25.05 https://github.com/nix-community/home-manager/pull/6617/files
  services.syncthing.tray.command = "syncthingtray --wait";
  # services.syncthing.tray.pachage = TODO?;
  # home.packages = with pkgs; [ syncthingtray-qt6 ];
}
