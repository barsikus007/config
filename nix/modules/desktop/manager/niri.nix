{ pkgs, username, ... }:
#? https://wiki.nixos.org/wiki/Niri
{
  imports = [
    ../default.nix
  ];
  home-manager.users.${username}.imports = [ ../../../home/desktop/manager/niri.nix ];

  services.displayManager.defaultSession = "niri";
  programs.niri.enable = true;

  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];

  programs.dms-shell = {
    # enable = true;
    systemd.enable = false;
  };
}
