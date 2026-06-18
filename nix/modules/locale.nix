{ pkgs, config, ... }:
#? comfort and rational settings for locales
{
  time.timeZone = "Europe/Moscow";
  i18n = {
    glibcLocales = (
      pkgs.callPackage ../packages/locales-iso.nix {
        locales = config.i18n.supportedLocales;
      }
    );
    extraLocaleSettings = {
      LC_COLLATE = "en_US.UTF-8"; # ? human readable ordering
      #! LC_CTYPE,LC_MEASUREMENT is skipped as unused
      #! LC_MESSAGES,LC_NAME is skipped as useless
      LC_MONETARY = "en_US.UTF-8"; # ? , as thousand separator
      LC_NUMERIC = "en_US.UTF-8"; # ? , as thousand separator
      LC_TIME = "en_SE.UTF-8"; # ? ISO time with icu support
      #? я русский
      LC_ADDRESS = "ru_RU.UTF-8";
      LC_TELEPHONE = "ru_RU.UTF-8";
    };
  };
}
