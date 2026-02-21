{ pkgs, config, ... }:
{
  #? content of programs.obs-studio.enableVirtualCamera
  boot = {
    kernelModules = [ "v4l2loopback" ];
    extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  };

  environment.systemPackages = with pkgs; [
    v4l-utils
    config.boot.kernelPackages.v4l2loopback
  ];
}
