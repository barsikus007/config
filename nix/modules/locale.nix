{
  lib,
  pkgs,
  config,
  ...
}:
{
  i18n = {
    glibcLocales = (
      import ../packages/locales-xx.nix {
        inherit pkgs;
        locales = config.i18n.supportedLocales;
      }
    );
    extraLocaleSettings = {
      LC_TIME = lib.mkForce "en_XX.UTF-8@POSIX";
    };
  };
}
