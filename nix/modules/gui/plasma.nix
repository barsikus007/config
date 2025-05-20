{ pkgs, ... }:
{
  environment.sessionVariables = {
    # https://wiki.nixos.org/wiki/Wayland#Electron_and_Chromium
    NIXOS_OZONE_WL = "1";
    # use KDE filepicker in GTK apps
    GTK_USE_PORTAL = "1";
  };
  # services.xserver.enable = true; # optional for sddm
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      # TODO idk what it does
      autoLogin.relogin = true;
    };
  };
  services.desktopManager.plasma6.enable = true;
  # environment.plasma6.excludePackages = with pkgs.kdePackages; [
  #   # https://github.com/NixOS/nixpkgs/blob/nixos-25.05/nixos/modules/services/desktop-managers/plasma6.nix#L159-L174
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
    kdePackages.filelight
    kdePackages.kclock
    kdePackages.kcalc

    #? for KDE Connect ?
    kdePackages.kdialog

    wl-clipboard
    libnotify
  ];
  programs.kdeconnect.enable = true;
}
