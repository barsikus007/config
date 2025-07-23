{
  lib,
  stdenv,
  patchPpdFilesHook,

  # cups,
  # glibc,
  # gcc-unwrapped,

  fetchzip,
  unrar,
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

  nativeBuildInputs = [ patchPpdFilesHook ];

  # buildInputs = [
  #   cups
  #   glibc
  #   gcc-unwrapped
  # ];

  installPhase = ''
    # runHook preInstall

    cd v${finalAttrs.version}/
    mkdir -p $out/lib/cups/filter/
    mkdir -p $out/share/cups/model/hprt/
    install -m 644 ppd/*.ppd $out/share/cups/model/hprt/
    install -m 755 -D filter/${installationPath}/* $out/lib/cups/filter/

    # runHook postInstall
  '';

  ppdFileCommands = [
    "raster-tspl"
  ];

  meta = with lib; {
    description = "MPrint drivers for label printers";
    homepage = "https://help.mertech.ru/label_printers/%D0%9E%D0%B1%D1%89%D0%B5%D0%B5/%D0%A3%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%BA%D0%B0_%D0%BF%D0%B0%D0%BA%D0%B5%D1%82%D0%B0_%D0%B4%D1%80%D0%B0%D0%B9%D0%B2%D0%B5%D1%80%D0%BE%D0%B2_%D0%B4%D0%BB%D1%8F_%D0%BF%D1%80%D0%B8%D0%BD%D1%82%D0%B5%D1%80%D0%BE%D0%B2.html";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.free;
    # license = licenses.unfree;
    platforms = lib.platforms.linux;
    maintainers = with maintainers; [
      barsikus007
    ];
  };
})
