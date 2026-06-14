{ pkgs, ... }:
{
  imports = [ ./wine.nix ];
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

  programs.gpu-screen-recorder.enable = true;
  programs.obs-studio = {
    #? https://wiki.nixos.org/wiki/OBS_Studio
    #? Missing hardware acceleration: Sometimes you need to set "Output Mode" to Advanced in settings Output tab to see the hardware accelerated Video Encoders options.
    enable = true;
    enableVirtualCamera = true;
    # optional Nvidia hardware acceleration
    package =
      with pkgs;
      (obs-studio.override {
        cudaSupport = true;
      });

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vaapi # optional AMD hardware acceleration
      obs-gstreamer
      obs-vkcapture
      looking-glass-obs
    ];
  };
}
