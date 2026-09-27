{
  lib,
  config,
  ...
}:
{
  custom.persist.home = {
    directories =
      lib.optional config.programs.firefox.enable ".config/mozilla/firefox"
      ++ lib.optional config.programs.brave.enable ".config/BraveSoftware"
      ++ lib.optional config.programs.libreoffice.enable ".config/libreoffice"
      ++ lib.optional config.services.easyeffects.enable ".config/easyeffects"
      ++ lib.optional config.services.ludusavi.enable ".config/ludusavi"
      ++ lib.optional config.programs.thunderbird.enable ".thunderbird"
      ++ lib.optional (config.programs.element-desktop.enable or false) ".config/Element"
      ++ lib.optionals (config.programs.nixcord.enable or false) [
        ".config/discord"
        ".config/vesktop"
      ]
      ++ lib.optional (config.programs.noctalia.enable or false) ".cache/noctalia"; # ? to disable prompt on startup

    files = lib.optional config.services.syncthing.tray.enable {
      file = ".config/syncthingtray.ini";
      method = "symlink";
    };
  };
}
