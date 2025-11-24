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
      substituteInPlace localedata/locales/C \
        --replace-fail 'd_fmt   "%m//%d//%y"' 'd_fmt   "%F"'
    '';
  })
