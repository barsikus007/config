{
  lib,
  pkgs,
  inputs,
  username,
  ...
}:
{
  disabledModules = [
    "system/activation/bootspec.nix"
    "system/activation/specialisation.nix"
  ];
  imports = [
    ./system/activation/bootspec.nix
    ./system/activation/specialisation.nix

    inputs.stylix.nixosModules.stylix
  ];
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

    targets = {
      plymouth.enable = false;
    };
  };

  specialisation.light = {
    generateBootEntry = false;
    configuration = {
      stylix = {
        base16Scheme = lib.mkForce "${pkgs.base16-schemes}/share/themes/github.yaml";
        image = lib.mkForce (
          pkgs.fetchurl {
            url = "https://w.wallhaven.cc/full/zy/wallhaven-zy3r2w.png";
            hash = "sha256-O9INURruZK+bW3ZJmSD1lj50MviTOiuLCa9j7SUehvY=";
          }
        );
        polarity = lib.mkForce "light";
      };
      # TODO: module: help me
      home-manager.users.${username}.programs.bat.config.theme = lib.mkForce "Coldark-Cold";
    };
  };
  security.sudo.extraRules = [
    {
      users = [ username ];
      commands = [
        {
          command = "/nix/var/nix/profiles/system/bin/switch-to-configuration";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/nix/var/nix/profiles/system/specialisation/light/bin/switch-to-configuration";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
