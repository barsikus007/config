{ pkgs, ... }:
{
  services.lact =
    let
      ids = import ../ids.nix;
      gpuConfig = curveFile: {
        fan_control_enabled = false;
        nvidia_gpu_vf_curve = builtins.fromJSON (builtins.readFile curveFile);
      };
      efficiencyConfig = gpuConfig ./gpu-vf-curve-568mv-1100mhz.json;
      performanceConfig = gpuConfig ./gpu-vf-curve-650mv-1365mhz.json;
    in
    {
      enable = true;
      settings = {
        version = 7;
        daemon.log_level = "info";
        current_profile = "UV Efficiency";
        profiles = {
          "UV Efficiency".gpus.${ids.gpu.discrete.lactId} = efficiencyConfig;
          "UV Performance".gpus.${ids.gpu.discrete.lactId} = performanceConfig;
        };
      };
    };
  systemd.services.lactd.serviceConfig.ExecStartPre = [
    "-${pkgs.coreutils}/bin/rm --force /run/lactd.sock"
    "${pkgs.coreutils}/bin/cp --remove-destination /etc/static/lact/config.yaml /etc/lact/config.yaml"
    "${pkgs.coreutils}/bin/chmod 644 /etc/lact/config.yaml"
  ];
}
