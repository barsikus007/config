{ pkgs, ... }:
{
  custom.persist.home.files = [
    {
      file = ".config/syncthingtray.ini";
      method = "symlink";
    }
  ];

  services.syncthing = {
    enable = true;
    tray = {
      enable = true;
      command = "syncthingtray --wait --single-instance";
      package = with pkgs; syncthingtray;
    };
  };
}
