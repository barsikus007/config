{ pkgs, config, ... }:
#? https://wiki.nixos.org/wiki/Dolphin
{
  programs.niri.useNautilus = false;

  xdg.portal.extraPortals = with pkgs; [ kdePackages.xdg-desktop-portal-kde ];
  xdg.portal.config.common."org.freedesktop.impl.portal.FileChooser" = [ "kde" ];

  #? Fix unpopulated MIME menus in dolphin: https://discourse.nixos.org/t/dolphin-does-not-have-mime-associations/48985/8
  environment.etc."xdg/menus/applications.menu" = {
    enable = !config.services.desktopManager.plasma6.enable;
    text = builtins.readFile "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
  };

  environment.systemPackages = with pkgs; [
    #? this is installed by xdg-desktop-portal-kde anyway
    kdePackages.plasma-workspace

    kdePackages.dolphin
    kdePackages.qtsvg
    kdePackages.kio
    kdePackages.kio-fuse
    kdePackages.kio-extras

    #? have issues with focus, it should focus to explorer every time
    # alias explorer.exe='kioclient exec'
    (writeShellScriptBin "explorer.exe" ''
      dolphin --new-window "$@" 1>/dev/null 2>/dev/null & disown
    '')
  ];
}
