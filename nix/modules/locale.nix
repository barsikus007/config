{
  pkgs,
  config,
  ...
}:
{
  i18n = {
    glibcLocales = (
      pkgs.callPackage ../packages/locale-cxx.nix {
        locales = config.i18n.supportedLocales;
      }
    );
  };
}
