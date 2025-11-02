{
  pkgs,
  locales ? [ "en_XX.UTF-8@POSIX" ],
  ...
}:
let
  locale-en_xx = pkgs.stdenv.mkDerivation rec {
    pname = "locale-en_xx";
    version = "2017";
    src = pkgs.fetchzip {
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
in
(pkgs.glibcLocales.override {
  allLocales = false;
  locales = locales;
}).overrideAttrs
  (old: {
    patchPhase = (old.patchPhase or "") + ''
      echo 'en_XX.UTF-8@POSIX/UTF-8 \' >> ../glibc-2*/localedata/SUPPORTED
      for glibc_root in ../glibc-2*/localedata/locales
      do
        cp "${locale-en_xx}/share/i18n/locales/en_XX@POSIX" "$glibc_root/en_XX@POSIX"
      done
    '';
  })
