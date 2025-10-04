{ pkgs, ... }:
{
  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    # image = pkgs.fetchurl {
    #   url = "https://www.pixelstalk.net/wp-content/uploads/2016/05/Epic-Anime-Awesome-Wallpapers.jpg";
    #   sha256 = "enQo3wqhgf0FEPHj2coOCvo7DuZv+x5rL/WIo4qPI50=";
    # };
    # cursor = {
    #   size = 24;
    #   package = pkgs.kdePackages.breeze;
    #   name = "breeze_cursors";
    # };
    polarity = "dark";

    fonts.serif.name = "Noto Sans";
    fonts.monospace = {
      package = pkgs.cascadia-code;
      name = "Cascadia Code NF";
    };
    fonts.sizes.applications = 10;
    fonts.sizes.terminal = 12;
  };
}
