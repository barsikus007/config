{ pkgs, ... }:
#? Да.
{
  imports = [
    ./discord.nix
    ./telegram.nix
  ];
  custom.persist.home.directories = [
    ".thunderbird"
    ".config/Element"
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
