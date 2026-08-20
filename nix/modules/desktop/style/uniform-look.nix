{
  lib,
  pkgs,
  username,
  ...
}:
#? https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications
#! JUST FUCK THIS SHIT: nix shell nixpkgs#kdePackages.qttools --command qdbus org.kde.kded6 /kded org.kde.kded6.loadModule gtkconfig
{
  home-manager.users.${username}.imports = [ ../../../home/desktop/style/uniform-look.nix ];

  environment.variables.QT_QPA_PLATFORMTHEME = lib.mkForce "kde";

  #? make qt.platform.theme=kde setting to work
  environment.systemPackages = with pkgs; [ kdePackages.plasma-integration ];
}
