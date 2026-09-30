{ pkgs, username, ... }:
#? https://wiki.nixos.org/wiki/KDE
{
  imports = [
    ../.
    ../dm/sddm.nix
    ../style/uniform-look.nix
    ../environment/explorer/dolphin.nix
    ../environment/kdeconnect.nix
    ../environment/kwallet.nix
    ../environment/win-apps.nix
  ];
  home-manager.users.${username}.imports = [ ../../../home/desktop/manager/plasma.nix ];

  services.desktopManager.plasma6.enable = true;

  xdg.portal.config.common.default = [ "kde" ];

  environment.systemPackages = with pkgs; [
    #? xdotool for plasma
    kdotool
  ];
}
