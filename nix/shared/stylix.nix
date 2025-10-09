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

    fonts = with pkgs; {
      serif = {
        package = noto-fonts;
        name = "Noto Serif";
      };
      sansSerif = {
        package = cascadia-code;
        name = "Noto Sans";
      };
      monospace = {
        package = cascadia-code;
        name = "Cascadia Code NF";
      };
      # TODO: 25.11: 🫪
      emoji.package = unstable.noto-fonts-color-emoji;
      sizes = {
        applications = 10;
        terminal = 12;
      };
    };
  };
}
