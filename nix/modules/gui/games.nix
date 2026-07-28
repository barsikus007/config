{ pkgs, ... }:
{
  imports = [
    ./obs.nix
    ./wine.nix
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    package = pkgs.steam.override {
      extraPkgs = (
        pkgs: with pkgs; [
          gamemode
        ]
      );
    };
    protontricks.enable = true;
    # gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;
  programs.gamescope.enable = true;
  environment.systemPackages = with pkgs; [
    protonup-qt

    #? overlay like msi afterburner
    mangohud

    r2modman

    (heroic.override {
      extraPkgs = pkgs: [
        gamescope
        gamemode
      ];
    })

    gpu-screen-recorder
    gpu-screen-recorder-gtk
  ];
}
