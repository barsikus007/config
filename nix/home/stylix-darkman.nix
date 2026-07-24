{ lib, pkgs, ... }:
let
  #! xdg-desktop-portal-gnome caches color-scheme at its process start
  systemctl = lib.getExe' pkgs.systemd "systemctl";
  defaultSwitchScript = /* shell */ ''
    ${systemctl} --user restart xdg-desktop-portal-gnome.service
  '';
in
{
  #! QT-based apps: https://github.com/telegramdesktop/tdesktop/issues/26370
  #! Dolphin drops its view-props xattr on this reload, so it bounds to dolphinViewProperties
  home.activation.notifyQtColorChange =
    lib.hm.dag.entryBetween [ "dolphinViewProperties" ] [ "writeBoundary" ]
      ''
        run ${lib.getExe' pkgs.glib "gdbus"} emit --session --object-path /KGlobalSettings --signal org.kde.KGlobalSettings.notifyChange 0 0
      '';
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
}
