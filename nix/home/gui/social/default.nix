{ pkgs, ... }:
#? Да.
{
  imports = [
    ./discord.nix
    ./telegram.nix
  ];
  programs.thunderbird = {
    enable = true;
    profiles.default = {
      isDefault = true;
      settings = {
        # "general.useragent.override" = "";
        # "privacy.donottrackheader.enabled" = true;
      };
    };
  };
  home.packages = with pkgs; [ element-desktop ];
}
