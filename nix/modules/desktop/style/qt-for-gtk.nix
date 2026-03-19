{ pkgs, username, ... }:
#? https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications#Set_the_preferred_portal_backend
#! JUST FUCK THIS SHIT: nix shell nixpkgs#kdePackages.qttools --command qdbus org.kde.kded6 /kded org.kde.kded6.loadModule gtkconfig
{
  home-manager.users.${username}.imports = [ ../../../home/desktop/style/qt-for-gtk.nix ];

  xdg.portal.config.common.default = [ "kde" ];

  environment.systemPackages = with pkgs; [
    #? The fallback for GNOME apps
    gnome-icon-theme
    #? gtk2 console warning fix
    gnome-themes-extra
  ];
}
