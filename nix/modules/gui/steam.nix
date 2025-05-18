{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    package = pkgs.steam.override {
      # TODO
      # withJava = true;
      extraPkgs = (
        pkgs: with pkgs; [
          gamemode
        ]
      );
    };
    # additional steam settings...
    # e.g. remotePlay.openFirewall = true;
  };

  # https://medium.com/@notquitethereyet_/gaming-on-nixos-%EF%B8%8F-f98506351a24
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;
  # TODO: https://wiki.nixos.org/wiki/Heroic_Games_Launcher#Optional_Dependencies
  environment.systemPackages = with pkgs; [
    protonup-qt

    r2modman

    mangohud

    (lutris.override {
      extraPkgs = pkgs: [
        gamescope
        gamemode
      ];
    })
    (heroic.override {
      extraPkgs = pkgs: [
        gamescope
        gamemode
      ];
    })
    bottles

    parsec-bin
  ];
}
