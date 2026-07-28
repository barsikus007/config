{ pkgs, ... }:
{
  programs.gpu-screen-recorder.enable = true;
  programs.obs-studio = {
    #? https://wiki.nixos.org/wiki/OBS_Studio
    #? missing hardware acceleration: sometimes you need to set "Output Mode" to Advanced in settings Output tab to see the hardware accelerated Video Encoders options
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
