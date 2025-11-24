{
  lib,
  pkgs,
  config,
  ...
}:
{
  i18n = {
    glibcLocales = (
      pkgs.callPackage ../packages/locales-xx.nix {
        locales = config.i18n.supportedLocales;
      }
    );
    extraLocaleSettings = {
      LC_TIME = lib.mkForce "en_XX.UTF-8@POSIX";
    };
  };
}
