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
    ../../../home/desktop/manager/noctalia-niri.nix
  ];

  services.displayManager.noctalia-greeter = {
    enable = true;
    cursorTheme = { inherit (config.stylix.cursor) name package; };
    passwordlessSyncUsers = [ username ];
    settings = {
      keyboard = { inherit (config.services.xserver.xkb) layout options; };
      output.scale = 1.0;
    };
  };

  environment.systemPackages = with pkgs; [ wdisplays ];
}
