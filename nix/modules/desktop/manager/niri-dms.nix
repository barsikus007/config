{ username, ... }:
#! +?Gb
{
  imports = [
    ./niri.nix
    ../../hardware/ddcutil.nix
    ../style/uniform-look.nix
    ../environment/explorer/dolphin.nix
    ../environment/kde-dbus.nix
    ../environment/kdeconnect.nix
    ../environment/kwallet.nix
    ../environment/win-apps.nix
  ];
  home-manager.users.${username}.imports = [
    ../../../home/desktop/environment/kde-settings.nix
    ../../../home/desktop/environment/kde-stylix.nix
    ../../../home/desktop/manager/quickshell/dms.nix
  ];

  services.displayManager.dms-greeter = {
    enable = true;
    configHome = "/home/${username}";
  };
  #? cause fprint is fucked up in dms
  security.pam.services.greetd.fprintAuth = false;

  programs.dsearch.enable = true;
}
