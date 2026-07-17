{
  lib,
  pkgs,
  username,
  ...
}:
let
  #! QT-based apps: https://github.com/telegramdesktop/tdesktop/issues/26370
  notifyQtColorChange = "${lib.getExe' pkgs.glib "gdbus"} emit --session --object-path /KGlobalSettings --signal org.kde.KGlobalSettings.notifyChange 0 0";
  #! xdg-desktop-portal-gnome caches color-scheme; restarting it unconditionally can kill ScreenCast
  notifyPortalRestart = pkgs.writeShellScript "notify-portal-restart" ''
    action=$(${lib.getExe pkgs.libnotify} -w -a darkman -A "restart=Restart portal" "Theme switched" "xdg-open windows kept the previous theme")
    if [ "$action" = "restart" ]; then
      ${lib.getExe' pkgs.systemd "systemctl"} --user restart xdg-desktop-portal-gnome.service
    fi
  '';
  defaultSwitchScript = /* shell */ ''
    ${notifyQtColorChange}
    ${notifyPortalRestart} &
    disown
  '';
in
{
  disabledModules = [
    "system/activation/bootspec.nix"
    "system/activation/specialisation.nix"
  ];
  imports = [
    ./system/activation/bootspec.nix
    ./system/activation/specialisation.nix
  ];
  home-manager.users.${username} = {
    services.darkman = {
      enable = true;
      darkModeScripts = {
        switch-to-dark = /* shell */ ''
          sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
          ${defaultSwitchScript}
        '';
      };
      lightModeScripts = {
        switch-to-light = /* shell */ ''
          sudo /nix/var/nix/profiles/system/specialisation/light/bin/switch-to-configuration switch
          ${defaultSwitchScript}
        '';
      };
      settings = {
        lat = 42;
        lng = 40;
        # usegeoclue = true;
      };
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
