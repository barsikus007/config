{
  lib,
  pkgs,
  config,
  username,
  ...
}:
#! +1.1Gb
{
  imports = [
    ./niri.nix
    ../style/qt-for-gtk.nix
    ../environment/win-apps.nix
    ../environment/explorer/dolphin.nix
    ../environment/kdeconnect.nix
  ];
  home-manager.users.${username}.imports = [
    ../../../home/desktop/environment/kde-settings.nix
    ../../../home/desktop/manager/quickshell/noctalia.nix
    {
      programs.niri.settings.spawn-at-startup = [
        {
          command = [
            "noctalia-shell"
          ];
        }
      ];
    }
  ];

  services.displayManager.gdm.enable = !config.services.displayManager.sddm.enable;

  #? power management: like in plasma module
  services.power-profiles-daemon.enable = lib.mkDefault true;
  services.upower.enable = config.powerManagement.enable;
  services.fwupd.enable = lib.mkDefault true;

  environment.systemPackages = with pkgs; [
    wdisplays
    kdePackages.qt6ct
  ];

  services.gnome.gnome-keyring.enable = false;
  xdg.portal.extraPortals = with pkgs; [ kdePackages.kwallet ];
  xdg.portal.config.common."org.freedesktop.impl.portal.Secret" = [ "kwallet" ];

  #? Fix unpopulated MIME menus in dolphin: https://discourse.nixos.org/t/dolphin-does-not-have-mime-associations/48985/8
  environment.etc."/xdg/menus/applications.menu".text =
    builtins.readFile "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
}
