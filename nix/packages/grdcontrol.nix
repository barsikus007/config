{
  stdenv,
  lib,

  fetchzip,
  dpkg,

  autoPatchelfHook,

  xorg,
}:
let
  pname = "grdcontrol";
  version = "4.4.3";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchzip {
    url = "https://download.guardant.ru/Guardant_Control_Center/${version}/grdcontrol-${version}_amd64.deb";
    hash = "sha256-1JvZaEPo6IEkcOVsx7PLW1fCUbbn/Bn89iz/4IAmZAs=";
    nativeBuildInputs = [ dpkg ];
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  propagatedBuildInputs = [
    xorg.libxcb
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,opt,lib}/
    # don't copy etc cause it contain only legacy init.d script
    cp -R opt $out/

    mkdir -p $out/lib/systemd/system/
    cp $out/opt/guardant/grdcontrol/grdcontrol.service $out/lib/systemd/system/
    substituteInPlace $out/opt/guardant/grdcontrol/grdcontrol.service \
      --replace-fail "/opt/guardant" "$out/opt/guardant"

    runHook postInstall
  '';

  dontBuild = true;

  meta = with lib; {
    description = "Professional solutions for software monetization and protection";
    homepage = "https://www.guardant.com/support/users/control-center/";
    platforms = with platforms; lists.intersectLists x86_64 linux;
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ barsikus007 ];
    mainProgram = "../opt/guardant/grdcontrol/grdcontrold";
  };
}
