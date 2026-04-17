{ config, ... }:
#? non-KDE desktops, which haven't look-and-feel
#? borrowed from stylix: https://github.com/nix-community/stylix/blob/e3861617645a43c9bbefde1aa6ac54dd0a44bfa9/modules/kde/hm.nix
let
  c = config.lib.stylix.colors;
  colorschemeSlug = builtins.concatStringsSep "" (
    builtins.filter builtins.isString (builtins.split "[^a-zA-Z]" c.scheme)
  );
  rgb =
    base: "${toString c."${base}-rgb-r"},${toString c."${base}-rgb-g"},${toString c."${base}-rgb-b"}";
  kdecolors = {
    BackgroundNormal = rgb "base00";
    BackgroundAlternate = rgb "base01";
    DecorationFocus = rgb "base0D";
    DecorationHover = rgb "base0D";
    ForegroundNormal = rgb "base05";
    ForegroundActive = rgb "base05";
    ForegroundInactive = rgb "base05";
    ForegroundLink = rgb "base05";
    ForegroundVisited = rgb "base05";
    ForegroundNegative = rgb "base08";
    ForegroundNeutral = rgb "base0D";
    ForegroundPositive = rgb "base0B";
  };
in
{
  programs.plasma.configFile = {
    "kdeglobals"."General"."ColorScheme" = colorschemeSlug;
    "kdeglobals"."Colors:Button" = kdecolors;
    "kdeglobals"."Colors:Complementary" = kdecolors;
    "kdeglobals"."Colors:Tooltip" = kdecolors;
    "kdeglobals"."Colors:View" = kdecolors;
    "kdeglobals"."Colors:Window" = kdecolors;
    "kdeglobals"."Colors:Selection" = kdecolors // {
      BackgroundNormal = rgb "base0D";
      BackgroundAlternate = rgb "base0D";
      ForegroundNormal = rgb "base00";
      ForegroundActive = rgb "base00";
      ForegroundInactive = rgb "base00";
      ForegroundLink = rgb "base00";
      ForegroundVisited = rgb "base00";
    };
  };
}
