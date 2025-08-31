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

  withTests ? false,
  cairo,
}:
#! 27c6:5110 -> 27c6:521d
#? https://github.com/lzc256/nur/blob/cfd1202a2b6988f408ef1116464c894f6d8d69be/pkgs/libfprint-27c6-5110/default.nix
#? https://github.com/0x00002a/libfprint/compare/0x2a/dev/goodixtls-sigfm...Infinytum:libfprint:driver/goodix-521d
#? https://aur.archlinux.org/packages/libfprint-goodix-521d
stdenv.mkDerivation {
  pname = "libfprint-27c6-521d";
  version = "uwu-0";

  #? https://github.com/Infinytum/libfprint/tree/driver/goodix-521d
  #? https://github.com/barsikus007/libfprint/tree/merge/upstream-1.94.9
  src = fetchFromGitHub {
    owner = "barsikus007";
    repo = "libfprint";
    rev = "merge/upstream-1.94.9";
    hash = "sha256-Zov/PfvKBfnoRUyUGsOsofrTt80kHq0eKCKlRXyvnio=";
  };

  #? https://gcc.gnu.org/gcc-14/porting_to.html#incompatible-pointer-types
  env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";

  patchPhase = ''
    # sed -i "4c       value: 'all')" ./meson_options.txt
    sed -i "8c       value: false)" ./meson_options.txt
    sed -i "16c       value: '$out/lib/udev')" ./meson_options.txt
    sed -i "24c       value: '$out/lib/udev')" ./meson_options.txt
    sed -i "32c       value: false)" ./meson_options.txt
    # sed -i "36c       value: false)" ./meson_options.txt
    cat ./meson_options.txt
  '';

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

  passthru.driverPath = "/lib";

  meta = with lib; {
    homepage = "https://github.com/infinytum/libfprint/tree/driver/goodix-521d";
    description = "(27c6:521d) Library for fingerprint readers";
    license = licenses.lgpl21Only;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
