{
  lib,
  multiStdenv,
  fetchFromGitHub,
}:

multiStdenv.mkDerivation rec {
  pname = "libspeedhack";
  version = "0.1-x86-multilib";

  src = fetchFromGitHub {
    owner = "evg-zhabotinsky";
    repo = pname;
    rev = version;
    hash = "sha256-+ymV3hWeNtnaUBPkbELhloQ1UVf1vAwXnPOMj2aun54=";
  };

  patches = [
    ./fix_paths.patch
  ];

  postPatch = ''
    substituteInPlace speedhack --replace-fail %OUT% $out
  '';

  buildPhase = ''
    make multilib
  '';

  installPhase = ''
    mkdir -p $out/lib/64 $out/lib/32 $out/bin
    cp lib64/* $out/lib/64
    cp lib32/* $out/lib/32
    cp speedhack $out/bin
  '';

  meta = with lib; {
    description = "A simple dynamic library to slowdown or speedup games on Linux Resources";
    homepage = "https://github.com/evg-zhabotinsky/libspeedhack";
    license = licenses.mit;
    maintainers = with maintainers; [
      tilcreator
      barsikus007
    ];
    platforms = platforms.x86_64;
  };
}
