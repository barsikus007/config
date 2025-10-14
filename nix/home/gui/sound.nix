{
  services.easyeffects.enable = true;
  dconf.settings."com/github/wwmm/easyeffects" = {
    process-all-inputs = true;
  };
  # https://github.com/Digitalone1/EasyEffects-Presets
  services.easyeffects.preset = "LoudnessEqualizer";
  xdg.configFile."easyeffects/output/LoudnessEqualizer.json".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/Digitalone1/EasyEffects-Presets/32d0f416e7867ccffdab16c7fe396f2522d04b2e/LoudnessEqualizer.json";
    hash = "sha256-lphnEyuRestYTEtspHhkpdG0n2oKzKfrX5L1X7wZB4k=";
  };
  xdg.configFile."easyeffects/output/LoudnessCrystalEqualizer.json".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/Digitalone1/EasyEffects-Presets/32d0f416e7867ccffdab16c7fe396f2522d04b2e/LoudnessCrystalEqualizer.json";
    hash = "sha256-cWzPSIM8C32pKpWCie6LV0hZIShEE/VU3x+u40c2DFU=";
  };
}
