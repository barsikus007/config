{ pkgs, username, ... }:
{
  environment.sessionVariables.QT_QPA_PLATFORM = "wayland;xcb";

  #? https://wiki.nixos.org/wiki/Wayland#Electron_and_Chromium
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  #? use xdg-desktop-portal filepicker in GTK apps
  xdg.portal.xdgOpenUsePortal = true;
  environment.sessionVariables.GTK_USE_PORTAL = "1";

  environment.systemPackages = with pkgs; [
    #? wayland stuff
    libnotify
    #? screenshot related
    grim
    slurp
    #? clipboardrelated
    wtype
    wl-clipboard

    #? spell check
    hunspell
    hunspellDicts.en_US-large
    hunspellDicts.ru_RU
  ];

  #? wayland stuff
  programs.ydotool.enable = true;
  users.users.${username}.extraGroups = [ "ydotool" ];
}
