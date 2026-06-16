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
    postPatch = (previousAttrs.postPatch or "") + /* shell */ ''
      cp localedata/locales/en_DK localedata/locales/en_SE
      echo 'en_SE.UTF-8/UTF-8 \' >> localedata/SUPPORTED
    '';
  })
