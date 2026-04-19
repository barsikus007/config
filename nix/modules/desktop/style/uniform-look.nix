{ pkgs, username, ... }:
#? https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications
#! JUST FUCK THIS SHIT: nix shell nixpkgs#kdePackages.qttools --command qdbus org.kde.kded6 /kded org.kde.kded6.loadModule gtkconfig
{
  home-manager.users.${username}.imports = [ ../../../home/desktop/style/uniform-look.nix ];

  environment.systemPackages = with pkgs; [
    #? make qt.platform.theme=kde setting to work
    kdePackages.plasma-integration
    #? The fallback for GNOME apps
    gnome-icon-theme
    #? gtk2 console warning fix
    gnome-themes-extra
  ];
}
