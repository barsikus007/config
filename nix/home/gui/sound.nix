{
  services.easyeffects.enable = true;
  # https://github.com/Digitalone1/EasyEffects-Presets
  services.easyeffects.preset = "LoudnessEqualizer";
  xdg.configFile."easyeffects/output/LoudnessEqualizer.json".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/Digitalone1/EasyEffects-Presets/32d0f416e7867ccffdab16c7fe396f2522d04b2e/LoudnessEqualizer.json";
    sha256 = "128736y5zxcjbzmsgk0adagv9ld5ciwa8v2b9iccnyli5c9ng64n";
  };
  xdg.configFile."easyeffects/output/LoudnessCrystalEqualizer.json".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/Digitalone1/EasyEffects-Presets/32d0f416e7867ccffdab16c7fe396f2522d04b2e/LoudnessCrystalEqualizer.json";
    sha256 = "0m8c6r3y7bhzvxaga4s450hmjj2pigp8k0lm5alps2rwhd4cyv3i";
  };
}
