{
  pkgs,
  config,
  username,
  ...
}:
#! +1.1Gb
{
  imports = [
    ./niri.nix
    ../../hardware/ddcutil.nix
    ../style/qt-for-gtk.nix
    ../environment/explorer/dolphin.nix
    ../environment/kde-dbus.nix
    ../environment/kdeconnect.nix
    ../environment/kwallet.nix
    ../environment/win-apps.nix
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

  environment.systemPackages = with pkgs; [ wdisplays ];

  #? Fix unpopulated MIME menus in dolphin: https://discourse.nixos.org/t/dolphin-does-not-have-mime-associations/48985/8
  environment.etc."/xdg/menus/applications.menu".text =
    builtins.readFile "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
}
