{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  cmake,
  gtk-doc,
  doctest,

  glib,
  gusb,
  gobject-introspection,

  pixman,
  openssl,
  libgudev,
  libfprint,

  withTests ? true,
  cairo,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libfprint-goodixtls-27c6-521d";
  version = "1.94.9";

  src = fetchFromGitHub {
    owner = "barsikus007";
    repo = "libfprint";
    rev = "merge/upstream-${finalAttrs.version}";
    hash = "sha256-Zov/PfvKBfnoRUyUGsOsofrTt80kHq0eKCKlRXyvnio=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    cmake
    gtk-doc
    doctest
  ];
  buildInputs = [
    glib
    gusb
    gobject-introspection

    pixman
    openssl
    libgudev
    libfprint
  ]
  ++ lib.optionals withTests [
    cairo
  ];

  mesonBuildType = "release";
  __structuredAttrs = true;
  strictDeps = true;

  # https://gcc.gnu.org/gcc-14/porting_to.html#incompatible-pointer-types
  env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";

  postPatch = ''
    # disable building GObject Introspection repository
    sed --in-place "8c       value: false)" ./meson_options.txt
    # set correct udev rules path for nix
    sed --in-place "16c       value: '$out/lib/udev')" ./meson_options.txt
    # set correct udev hwdb path for nix
    sed --in-place "24c       value: '$out/lib/udev')" ./meson_options.txt
    # don't build API docs
    sed --in-place "32c       value: false)" ./meson_options.txt
  ''
  + lib.strings.optionalString (!withTests) ''
    # don't install tests
    sed --in-place "36c       value: false)" ./meson_options.txt
  '';

  meta = {
    homepage = "https://github.com/infinytum/libfprint/tree/driver/goodix-521d";
    description = "(27c6:521d) Library for fingerprint readers";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ barsikus007 ];
    platforms = lib.platforms.linux;
  };
})
