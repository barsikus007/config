{ pkgs, ... }:
{
  environment.sessionVariables = {
    #? https://wiki.nixos.org/wiki/Wayland#Electron_and_Chromium
    NIXOS_OZONE_WL = "1";
    #? use KDE filepicker in GTK apps
    GTK_USE_PORTAL = "1";
  };
  #? use KDE filepicker in GTK apps
  xdg.portal.xdgOpenUsePortal = true;
  #? https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications#Set_the_preferred_portal_backend
  xdg.portal.config.common.default = [ "kde" ];
  xdg.portal.config.common."org.freedesktop.impl.portal.FileChooser" = [ "kde" ];

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      autoLogin.relogin = true;
    };
  };
  services.desktopManager.plasma6.enable = true;
  # environment.plasma6.excludePackages = with pkgs.kdePackages; [
  #   #? https://github.com/NixOS/nixpkgs/blob/nixos-25.05/nixos/modules/services/desktop-managers/plasma6.nix#L159-L174
  #   # plasma-browser-integration
  #   # konsole
  #   # (lib.getBin qttools) # Expose qdbus in PATH
  #   # ark
  #   # elisa
  #   # gwenview
  #   # okular
  #   # kate
  #   # khelpcenter
  #   # dolphin
  #   # baloo-widgets # baloo information in Dolphin
  #   # dolphin-plugins
  #   # spectacle
  #   # ffmpegthumbs
  #   # krdp
  #   # xwaylandvideobridge # exposes Wayland windows to X11 screen capture
  # ];
  environment.defaultPackages = with pkgs; [
    # https://wiki.nixos.org/wiki/Dolphin
    kdePackages.qtsvg
    kdePackages.kio
    kdePackages.kio-fuse
    kdePackages.kio-extras

    #? KDE apps, which are analog to useful Windows apps
    kdePackages.filelight
    kdePackages.kclock
    kdePackages.kcalc

    #? ydotool for plasma
    kdotool

    #? for KDE Connect
    kdePackages.kdialog
    # https://invent.kde.org/network/kdeconnect-kde/-/tree/master/plugins/virtualmonitor
    kdePackages.krfb
  ];
  programs.kdeconnect.enable = true;
}
