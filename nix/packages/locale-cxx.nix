{
  glibcLocales,
  locales ? [ "en_US.UTF-8/UTF-8" ],
  ...
}:
(glibcLocales.override {
  allLocales = false;
  locales = locales;
}).overrideAttrs
  (previousAttrs: {
    patchPhase = (previousAttrs.patchPhase or "") + ''
      substituteInPlace localedata/locales/en_GB \
        --replace-fail 'd_fmt       "%d//%m//%y"' 'd_fmt       "%F"'
    '';
  })
