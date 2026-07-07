{ pkgs, config, ... }:
#? stolen from https://github.com/Spliterash/nix-config/blob/78aec7fd5e0bca659c2e205fc7e1291b5d6e734b/home/soft/furryfox/furryfox.nix
let
  furryIcon = pkgs.fetchurl {
    name = "furryicon";
    #? https://e621.net/posts/5480197
    # url = "https://drive.usercontent.google.com/download?id=1DRqgAnzfJS2Q911biLPUOpd28HCH1F2A&export=download&authuser=0&confirm=t&uuid=04a8ef2f-a1db-4e6f-8ec4-71f45e5f4adb&at=AAINaILDKbY86gTaXEpyEDYpAKWR:1781380863359";
    # sha256 = "sha256-OQl0nr2HIFADLtFnSnwlMw4bsENlipuZJyAso02aPvU=";
    #? https://e621.net/posts/3523763
    url = "https://static1.e621.net/data/8f/2a/8f2a8f8adc45a7647cb3101d7c295160.png";
    sha256 = "sha256-UxK5froK6CQfwgwdCk716fY20hkb9jgMdGui8yZ+FY8=";
  };
  iconSizes = [
    "16x16"
    "32x32"
    "48x48"
    "64x64"
    "128x128"
    "256x256"
  ];
  mkIcon =
    size:
    pkgs.runCommandLocal "furryfox-icon-${size}.png"
      {
        nativeBuildInputs = [ pkgs.imagemagick ];
        # } "magick ${furryIcon} -resize ${size} png:$out";
      }
      /* shell */ ''
        read -r W H < <(magick identify -format "%w %h\n" ${furryIcon})
        magick ${furryIcon} \
          -fill white -draw "ellipse 450,330 410,350 0,360" \
          -alpha set -fill none -fuzz 15% \
          -draw "color 0,0 floodfill" \
          -draw "color $((W-1)),0 floodfill" \
          -draw "color 0,$((H-1)) floodfill" \
          -draw "color $((W-1)),$((H-1)) floodfill" \
          -trim +repage \
          -resize ${size} \
          png:$out
      '';
in
{
  xdg.dataFile =
    builtins.listToAttrs (
      map (s: {
        name = "icons/hicolor/${s}/apps/firefox.png";
        value.source = mkIcon s;
      }) iconSizes
    )
    // {
      "applications/firefox.desktop".text =
        builtins.replaceStrings [ "Name=Firefox" ] [ "Name=FurryFox" ]
          (builtins.readFile "${config.programs.firefox.finalPackage}/share/applications/firefox.desktop");
    };
}
