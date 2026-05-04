{
  lib,
  pkgs,
  config,
  inputs,
  username,
  ...
}:
#? https://wiki.nixos.org/wiki/Niri
{
  #? https://github.com/sodiboo/niri-flake/blob/c175f415488243723dc1a5514b286abbea6f93c1/flake.nix#L479
  nix.settings.extra-substituters = [ "https://niri.cachix.org" ];
  nix.settings.extra-trusted-public-keys = [
    "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
  ];
  nixpkgs.overlays = [
    (final: prev: {
      niri = inputs.niri.packages.${prev.stdenv.hostPlatform.system}.niri-unstable;
      xwayland-satellite =
        inputs.niri.packages.${prev.stdenv.hostPlatform.system}.xwayland-satellite-unstable;
    })
  ];

  imports = [
    ../.
  ];
  home-manager.users.${username}.imports = [ ../../../home/desktop/manager/niri.nix ];

  services.displayManager.defaultSession = "niri";
  services.displayManager.dms-greeter.compositor.name = "niri";
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
    xlsclients
  ];
}
