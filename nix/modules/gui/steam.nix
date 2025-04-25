{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    # TODO
    # package = pkgs.steam.override { withJava = true; };
  };
}
