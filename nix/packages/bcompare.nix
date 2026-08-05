{ fetchurl, bcompare }:
let
  #? https://www.scootersoftware.com/download/v5changelog
  version = "5.2.4.32425";

  src = fetchurl {
    url = "https://www.scootersoftware.com/files/bcompare-${version}_amd64.deb";
    sha256 = "sha256-gXmz7ZgTLPNzqckzKV7r+B8V0oS10/GQNTM0/0EYs3s=";
  };
in
(bcompare.overrideAttrs (previousAttrs: {
  inherit src version;

  installPhase = (previousAttrs.installPhase or "") + /* bash */ ''
    #? prefer native wayland (fixes DnD via xwayland bridge), fall back to xcb on X sessions
    substituteInPlace $out/bin/bcompare \
      --replace-fail "QT_QPA_PLATFORM=xcb" 'QT_QPA_PLATFORM="wayland;xcb"'
  '';
}))
