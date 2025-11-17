{ pkgs, ... }:
{
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
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;
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

    # native wayland support (unstable)
    wineWowPackages.unstableFull
    winetricks
    bottles

    gpu-screen-recorder-gtk
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
