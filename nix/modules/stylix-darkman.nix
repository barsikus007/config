{
  lib,
  pkgs,
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
  home-manager.users.${username}.imports = [ ../home/stylix-darkman.nix ];

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
      home-manager.users.${username} = {
        programs.bat.config.theme = lib.mkForce "Coldark-Cold";
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
