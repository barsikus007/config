{ pkgs, inputs, ... }:
#? https://openwrt.org/toh/xiaomi/ax3600
#? https://openwrt.org/toh/hwdata/xiaomi/xiaomi_ax3600
#  Package architecture: aarch64_cortex-a53
let
  profiles = inputs.openwrt-imagebuilder.lib.profiles { inherit pkgs; };
  profile = profiles.identifyProfile "xiaomi_ax3600" // {
    #? specify release
    # release = "25.12.6";
  };
  arch = profiles.allProfiles.${profile.target}.${profile.variant}.arch_packages;
  common = import ./. { inherit pkgs arch profile; };
in
inputs.openwrt-imagebuilder.lib.build (profile // common)
