{ pkgs, config, ... }:
{
  services.easyeffects.enable = true;
  dconf.settings."com/github/wwmm/easyeffects" = {
    process-all-inputs = true;
  };
  # https://github.com/Digitalone1/EasyEffects-Presets
  services.easyeffects.preset = "LoudnessEqualizer";
  services.easyeffects.extraPresets = {
    LoudnessEqualizer = builtins.fromJSON (
      builtins.readFile (
        builtins.fetchurl {
          url = "https://raw.githubusercontent.com/Digitalone1/EasyEffects-Presets/69567deb8284a0c93975f2655b63c8246b320a31/LoudnessEqualizer.json";
          sha256 = "sha256-1vVMz+X+Zxldo7ull6FL3IGdvzuDO3nNosE3nPclvKw=";
        }
      )
    );
    LoudnessCrystalEqualizer = builtins.fromJSON (
      builtins.readFile (
        builtins.fetchurl {
          url = "https://raw.githubusercontent.com/Digitalone1/EasyEffects-Presets/69567deb8284a0c93975f2655b63c8246b320a31/LoudnessCrystalEqualizer.json";
          sha256 = "sha256-Wqq6ltbAmfqMc8tkq977LKtLzrO6R69hV+i5KrVWLWo=";
        }
      )
    );
  };

  # TODO: unstable: https://github.com/nix-community/home-manager/pull/8192
  systemd.user.services.easyeffects.Service = {
    ExecStart = pkgs.lib.mkForce "${pkgs.easyeffects}/bin/easyeffects --hide-window --service-mode ${
      pkgs.lib.optionalString (
        config.services.easyeffects.preset != ""
      ) "--load-preset ${config.services.easyeffects.preset}"
    }";
    Type = pkgs.lib.mkForce "";
    BusName = pkgs.lib.mkForce "";
  };
}
