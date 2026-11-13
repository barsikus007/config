{
  lib,
  pkgs,
  config,
  ...
}:
{
  boot =
    lib.mkIf (!(config.programs.obs-studio.enable && config.programs.obs-studio.enableVirtualCamera))
      {
        kernelModules = [ "v4l2loopback" ];
        extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
      };

  environment.systemPackages = with pkgs; [
    v4l-utils
    config.boot.kernelPackages.v4l2loopback.bin
  ];
}
