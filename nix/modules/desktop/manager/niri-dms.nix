{ pkgs, username, ... }:
#! +?Gb
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
    ../../../home/desktop/manager/quickshell/dms.nix
  ];

  services.displayManager.dms-greeter = {
    enable = true;
    configHome = "/home/${username}";
  };
  #? cause fprint is fucked up in dms
  security.pam.services.greetd.fprintAuth = false;

  programs.dsearch.enable = true;

  #? Fix unpopulated MIME menus in dolphin: https://discourse.nixos.org/t/dolphin-does-not-have-mime-associations/48985/8
  environment.etc."/xdg/menus/applications.menu".text =
    builtins.readFile "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
}
