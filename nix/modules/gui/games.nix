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

    # https://github.com/DarthPJB/parsec-gaming-nix
    parsec-bin
  ];

  programs.gpu-screen-recorder.enable = true;
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    # optional Nvidia hardware acceleration
    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vaapi # optional AMD hardware acceleration
      obs-gstreamer
      obs-vkcapture
    ];
  };
}
