{ pkgs, username, ... }:
#? https://wiki.nixos.org/wiki/KDE
{
  imports = [
    ../default.nix
    ../dm/sddm.nix
    ../style/qt-for-gtk.nix
    ../environment/explorer/dolphin.nix
    ../environment/kdeconnect.nix
    ../environment/kwallet.nix
    ../environment/win-apps.nix
  ];
  home-manager.users.${username}.imports = [ ../../../home/desktop/manager/plasma.nix ];

  xdg.portal.config.common.default = [ "kde" ];

  #! still raw in terms of fprintd things
  # services.displayManager.plasma-login-manager.enable = true;
  services.desktopManager.plasma6.enable = true;
  environment.systemPackages = with pkgs; [
    #? xdotool for plasma
    kdotool
  ];
}
