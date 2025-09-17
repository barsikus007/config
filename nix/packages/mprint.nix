{
  lib,
  stdenv,

  fetchzip,
  unrar,

  patchPpdFilesHook,
  autoPatchelfHook,

  cups,
  krb5,
  e2fsprogs,
  libxcrypt-legacy,
}:
let
  installationPath = if stdenv.hostPlatform.system == "x86_64-linux" then "x64" else "x86";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "mprint";
  version = "1.2.1";

  src = fetchzip {
    url = "https://files.mertech.ru/help/general/label/mprint%20linux%20driver%20v1.2.0-1.2.2.rar";
    hash = "sha256-q/p/OvPfj95yZNmZFxiZkL/7biOAGqSh6oIzT2Xi5jk=";
    nativeBuildInputs = [ unrar ];
  };

  nativeBuildInputs = [
    patchPpdFilesHook
    autoPatchelfHook
  ];

  buildInputs = [
    cups
    krb5
    e2fsprogs
    libxcrypt-legacy
  ];

  installPhase = ''
    runHook preInstall

    cd v${finalAttrs.version}/
    mkdir -p $out/lib/cups/filter/
    mkdir -p $out/share/cups/model/hprt/
    install -m 644 ppd/*.ppd $out/share/cups/model/hprt/
    install -m 755 -D filter/${installationPath}/* $out/lib/cups/filter/

    runHook postInstall
  '';

  ppdFileCommands = [
    "raster-tspl"
  ];

  meta = with lib; {
    description = "MPrint drivers for label printers";
    homepage = "https://help.mertech.ru/label_printers/Общее/Установка_пакета_драйверов_для_принтеров.html";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = with maintainers; [
      barsikus007
    ];
  };
})
