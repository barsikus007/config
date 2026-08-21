{ pkgs, ... }:
{
  custom.persist.home.directories = [ ".config/obs-studio" ];

  #? https://github.com/nixos-cuda/infra
  nix.settings.extra-substituters = [ "https://cache.nixos-cuda.org" ];
  nix.settings.extra-trusted-public-keys = [
    "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
  ];

  programs.gpu-screen-recorder.enable = true;
  programs.obs-studio = {
    #? https://wiki.nixos.org/wiki/OBS_Studio
    #? missing hardware acceleration: sometimes you need to set "Output Mode" to Advanced in settings Output tab to see the hardware accelerated Video Encoders options
    enable = true;
    enableVirtualCamera = true;
    # optional Nvidia hardware acceleration
    package = pkgs.obs-studio.override { cudaSupport = true; };

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
