{
  lib,
  pkgs,
  config,
  ...
}:
#? https://wiki.nixos.org/wiki/KDE
{
  imports = [
    ../default.nix
  ];

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
  #? https://wiki.nixos.org/wiki/Fingerprint_scanner#Login
  #! https://github.com/NixOS/nixpkgs/issues/171136#issuecomment-2918400189
  security.pam.services.sddm.text = (
    lib.strings.concatLines (
      builtins.filter (x: (lib.strings.hasPrefix "auth " x) && (!lib.strings.hasInfix "fprintd" x)) (
        lib.strings.splitString "\n" config.security.pam.services.login.text
      )
    )
    + ''

      account   include   login
      password  substack  login
      session   include   login
    ''
  );

  services.desktopManager.plasma6.enable = true;
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

    #? xdotool for plasma
    kdotool

    #? for KDE Connect
    kdePackages.kdialog
    # https://invent.kde.org/network/kdeconnect-kde/-/tree/master/plugins/virtualmonitor
    kdePackages.krfb
  ];
  programs.kdeconnect.enable = true;
}
