{ pkgs, username, ... }:
#? https://wiki.nixos.org/wiki/KDE_Connect
{
  programs.kdeconnect.enable = true;
  home-manager.users.${username}.services.kdeconnect.enable = true;

  environment.systemPackages = with pkgs; [
    kdePackages.kdialog
    #? https://invent.kde.org/network/kdeconnect-kde/-/tree/master/plugins/virtualmonitor
    kdePackages.krfb
    #? https://noctalia.dev/plugins/kde-connect/
    kdePackages.qttools

    #? for non-dolphin mounting
    sshfs
  ];
}
