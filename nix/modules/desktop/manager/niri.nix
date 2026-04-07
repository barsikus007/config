{
  lib,
  pkgs,
  config,
  username,
  ...
}:
#? https://wiki.nixos.org/wiki/Niri
{
  imports = [
    ../default.nix
  ];
  home-manager.users.${username}.imports = [ ../../../home/desktop/manager/niri.nix ];

  services.displayManager.defaultSession = "niri";
  programs.niri.enable = true;

  #? cause it it set by module with no configuration, overriding the common settings
  xdg.portal.config.niri."org.freedesktop.impl.portal.FileChooser" = lib.mkIf (
    config.xdg.portal.config.common ? "org.freedesktop.impl.portal.FileChooser"
  ) (lib.mkForce config.xdg.portal.config.common."org.freedesktop.impl.portal.FileChooser");
  xdg.portal.config.niri."org.freedesktop.impl.portal.Secret" = lib.mkIf (
    config.xdg.portal.config.common ? "org.freedesktop.impl.portal.Secret"
  ) (lib.mkForce config.xdg.portal.config.common."org.freedesktop.impl.portal.Secret");

  environment.sessionVariables = {
    #? fix messed fonts in java GUI apps
    #? for <=jdk8 _JAVA_OPTIONS
    _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true";
    JDK_JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true";
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];
}
