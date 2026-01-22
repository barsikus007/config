{ pkgs, ... }:
{
  services.syncthing = {
    enable = true;
    tray = {
      enable = true;
      command = "syncthingtray --wait --single-instance";
      package = with pkgs; syncthingtray;
    };
  };
}
