{
  stdenv,
  fetchzip,
  glibcLocales,
  locales ? [ "en_XX.UTF-8@POSIX" ],
  ...
}:
let
  locale-en_xx = stdenv.mkDerivation rec {
    pname = "locale-en_xx";
    version = "2017";
    src = fetchzip {
      url = "https://xyne.dev/projects/locale-en_xx/src/${pname}-${version}.tar.xz";
      hash = "sha256-EgvEZ5RVNMlDyzIPIpfr8hBD6lGbljtXhE4IjzJDq9I=";
    };
    installPhase = ''
      runHook preInstall

      install -Dm644 "en_XX@POSIX" "$out/share/i18n/locales/en_XX@POSIX"

      runHook postInstall
    '';
    meta = {
      description = "A mixed international English locale with ISO and POSIX formats for cosmopolitan coders";
      homepage = "https://xyne.dev/projects/locale-en_xx";
    };
  };
  locale-en_xx-ampmless = locale-en_xx.overrideAttrs {
    installPhase = ''
      runHook preInstall

      install -Dm644 "en_XX@POSIX" "$out/share/i18n/locales/en_XX@POSIX"
      substituteInPlace $out/share/i18n/locales/en_XX@POSIX \
        --replace-fail '"AM";"PM"' '"";""' \
        --replace-fail 't_fmt_ampm ""' 't_fmt_ampm "%T"'

      runHook postInstall
    '';
  };
in
(glibcLocales.override {
  allLocales = false;
  locales = locales;
}).overrideAttrs
  (previousAttrs: {
    patchPhase = (previousAttrs.patchPhase or "") + ''
      echo 'en_XX.UTF-8@POSIX/UTF-8 \' >> ../glibc-2*/localedata/SUPPORTED
      for glibc_root in ../glibc-2*/localedata/locales
      do
        cp "${locale-en_xx}/share/i18n/locales/en_XX@POSIX" "$glibc_root/en_XX@POSIX"
      done
    '';
        # cp "${locale-en_xx-ampmless}/share/i18n/locales/en_XX@POSIX" "$glibc_root/en_XX@POSIX"
  })
