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
  #? https://github.com/NixOS/nixpkgs/blob/d960d804370080d9ba0d4d197c3269e7e001b0e3/nixos/modules/services/desktop-managers/plasma6.nix#L151-L169
  # environment.plasma6.excludePackages = with pkgs.kdePackages; [ ];
  environment.systemPackages = with pkgs; [
    #? The fallback for GNOME apps
    gnome-icon-theme
    #? gtk2 console warning fix
    gnome-themes-extra

    #? https://wiki.nixos.org/wiki/Dolphin
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
