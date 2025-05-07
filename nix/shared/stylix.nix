{ pkgs, ... }:
{
  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    # TODO: unstable 25.05 https://github.com/danth/stylix/pull/943
    image = pkgs.fetchurl {
      url = "https://www.pixelstalk.net/wp-content/uploads/2016/05/Epic-Anime-Awesome-Wallpapers.jpg";
      sha256 = "enQo3wqhgf0FEPHj2coOCvo7DuZv+x5rL/WIo4qPI50=";
    };
    cursor = {
      size = 24;
      package = pkgs.kdePackages.breeze;
      name = "breeze_cursors";
    };
    polarity = "dark";
    fonts.monospace = {
      package = pkgs.cascadia-code;
      name = "Cascadia Code NF";
    };
    targets = {
      gtk.enable = false;
      gnome.enable = false;
    };
  };
}
