{ pkgs, username, ... }:
#? https://wiki.nixos.org/wiki/Niri
{
  imports = [
    ../default.nix
  ];
  home-manager.users.${username}.imports = [ ../../../home/desktop/manager/niri.nix ];

  services.displayManager.defaultSession = "niri";
  programs.niri.enable = true;
  environment.sessionVariables = {
    #? for <=jdk8 _JAVA_OPTIONS
    _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true";
    JDK_JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true";
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];
}
