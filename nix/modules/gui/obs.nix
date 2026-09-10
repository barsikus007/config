{ pkgs, ... }:
{
  custom.persist.home.directories = [
    ".config/gpu-screen-recorder"
    ".config/obs-studio"
  ];

  #? https://github.com/nixos-cuda/infra
  nix.settings.extra-substituters = [ "https://cache.nixos-cuda.org" ];
  nix.settings.extra-trusted-public-keys = [
    "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
  ];

  programs.gpu-screen-recorder = {
    #? https://wiki.nixos.org/wiki/Gpu-screen-recorder
    enable = true;
    ui.enable = true;
  };
  programs.obs-studio = {
    #? https://wiki.nixos.org/wiki/OBS_Studio
    enable = true;
    package = pkgs.obs-studio.override { cudaSupport = true; };

    enableVirtualCamera = true;

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
