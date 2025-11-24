{ minecraftia, fetchzip }:
(minecraftia.overrideAttrs {
  version = "2.0";

  src = fetchzip {
    url = "https://dl.dafont.com/dl/?f=minecraftia";
    hash = "sha256-Nr/ujZsM4iG9DdKyY03d9aR0A+ND5H/cbUDBRnCDrMs=";
    extension = "zip";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    install -D -m444 -t $out/share/fonts/truetype $src/Minecraftia-Regular.ttf

    runHook postInstall
  '';
})
