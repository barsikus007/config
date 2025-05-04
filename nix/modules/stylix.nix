{ pkgs, ... }:
{
  stylix = {
    enable = true;
    # targets.qt.enable = false;
    # targets.wezterm.enable = true;
    # homeManagerIntegration.autoImport = true;
    # homeManagerIntegration.followSystem = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    image = pkgs.fetchurl {
      url = "https://www.pixelstalk.net/wp-content/uploads/2016/05/Epic-Anime-Awesome-Wallpapers.jpg";
      sha256 = "enQo3wqhgf0FEPHj2coOCvo7DuZv+x5rL/WIo4qPI50=";
    };
    # polarity = "dark";
    fonts.monospace = {
      package = pkgs.cascadia-code;
      name = "Cascadia Code NF";
    };
  };
}
