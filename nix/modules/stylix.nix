{
  pkgs,
  inputs,
  username,
  ...
}:
#! 580Mb
{
  imports = [
    inputs.stylix.nixosModules.stylix

    # ./stylix-darkman.nix
  ];
  home-manager.users.${username}.imports = [ ../home/stylix.nix ];

  stylix = {
    #? shared
    enable = true;
    # autoEnable = false;
    #? https://github.com/tinted-theming/schemes/tree/spec-0.11/base16
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/shades-of-purple.yaml";
    image = pkgs.fetchurl {
      url = "https://w.wallhaven.cc/full/8o/wallhaven-8o5o7k.jpg";
      hash = "sha256-jpN1gQ8RfDuBBfV4h3un0VvCm7FUy334YO1ibnYvmqk=";
    };
    cursor = {
      size = 24;
      package = with pkgs; kdePackages.breeze;
      name = "breeze_cursors";
    };
    # TODO: options: blur
    opacity = {
      desktop = 0.75;
      popups = 0.75;
      terminal = 0.85;
    };
    polarity = "dark";

    fonts = with pkgs; {
      serif = {
        package = noto-fonts;
        name = "Noto Serif";
      };
      sansSerif = {
        package = noto-fonts;
        name = "Noto Sans";
      };
      monospace = {
        package = cascadia-code;
        name = "Cascadia Code NF";
      };
      sizes = {
        applications = 10;
        terminal = 12;
      };
    };

    icons = {
      enable = true;
      light = "breeze";
      dark = "breeze-dark";
      package = with pkgs; kdePackages.breeze-icons;
    };

    targets = {
      #! `qt.platform` is ignored, and calculates from real system state
      # qt.enable = false;
      #? I don't like how it looks
      plymouth.enable = false;
      #? it triggers gdm and gnome-shell rebuilds
      gnome.enable = false;
      #? nixos-icons -> gschema.override -> gdm -> gnome-shell chain causes cache misses
      nixos-icons.enable = false;
    };
  };
}
