{
  lib,
  pkgs,
  config,
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
  ];
  home-manager.users.${username}.services.darkman = {
    enable = true;
    darkModeScripts = {
      switch-to-dark = "sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch";
    };
    lightModeScripts = {
      switch-to-light = "sudo /nix/var/nix/profiles/system/specialisation/light/bin/switch-to-configuration switch";
    };
    settings = {
      lat = 42;
      lng = 40;
      # usegeoclue = true;
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
      home-manager.users.${username} = {
        programs.bat.config.theme = lib.mkForce "Coldark-Cold";
        # TODO: niri cfg broken if plasma non-imported
        # home.file.".themes/Breeze-Dark" =
        #   config.home-manager.users.${username}.home.file.".themes/Breeze-Dark";
      };
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
