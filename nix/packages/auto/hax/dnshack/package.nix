{
  lib,
  cereal,
  cmake,
  fetchFromGitHub,
  fetchurl,
  stdenv,
}:

let
  version = "0.1.0";
  resolverBin = fetchurl {
    url = "https://github.com/ettom/dnshack/releases/download/v${version}/dnshackresolver-bin-v${version}";
    hash = "sha256-EIE2dMK/EFGPIeBi43VPwlMb19NUcDhtj6OxbSlaJoI=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "dnshack";
  inherit version;

  src = fetchFromGitHub {
    owner = "ettom";
    repo = "dnshack";
    rev = "58bbba6d2873d3dfdb65699bf0376b1856e74b9f";
    hash = "sha256-KFzzPd1Yjko+aBST0yGC7KR4ENitT6fQqaaJZBAMGcs=";
  };

  sourceRoot = "${finalAttrs.src.name}/dnshackbridge";

  nativeBuildInputs = [ cmake ];
  buildInputs = [ cereal ];

  patches = [
    ./restore-preload-and-resolver-path.patch
  ];

  postPatch = ''
    substituteInPlace dnshackbridge.cpp \
      --replace-fail '@RESOLVER_BIN@' "$out/bin/dnshackresolver"
  '';

  postInstall = ''
    install -m 755 -D ${resolverBin} $out/bin/dnshackresolver
  '';

  meta = {
    description = "Android DNS resolution bridge for glibc under proot";
    homepage = "https://github.com/ettom/dnshack";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
})
