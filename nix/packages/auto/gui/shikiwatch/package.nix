{
  lib,
  appimageTools,
  copyDesktopItems,
  fetchurl,
  makeDesktopItem,
  python3,
}:
let
  pname = "shikiwatch";
  version = "0.16.0";

  src = fetchurl {
    url = "https://github.com/wheremyfiji/ShikiWatch/releases/download/v${version}/ShikiWatch-${version}-linux-x64.AppImage";
    hash = "sha256-yQwpPKyZvni6M5LF1TNtTb6RcDcKBeDmlFyN+jImzRQ=";
  };
  appimageContents = appimageTools.extract {
    inherit pname version src;
    postExtract = /* shell */ ''
      chmod +x $out/usr/bin/lib/crashpad_handler
      ${lib.getExe python3} ${./patch-flutter-lcxx.py} $out/usr/bin/lib/libflutter_linux_gtk.so
    '';
  };
in
appimageTools.wrapAppImage (finalAttrs: {
  inherit pname version src;
  contents = appimageContents;

  nativeBuildInputs = [ copyDesktopItems ];

  extraPkgs =
    pkgs: with pkgs; [
      curl
      libsoup_3
      libepoxy
      libva
      webkitgtk_4_1
      gnutls
      libunwind
      libarchive
      libxv
    ];

  # GDK_BACKEND=x11
  desktopItems = [
    (makeDesktopItem {
      name = finalAttrs.pname;
      exec = finalAttrs.pname;
      icon = finalAttrs.pname;
      desktopName = finalAttrs.pname;
      type = "Application";
      comment = finalAttrs.meta.description;
      categories = [
        "AudioVideo"
        "Video"
        "Network"
      ];
    })
  ];

  extraInstallCommands = /* shell */ ''
    install -D --mode=444 ${appimageContents}/usr/share/icons/hicolor/256x256/apps/ShikiWatch.png \
      $out/share/icons/hicolor/256x256/apps/ShikiWatch.png
    copyDesktopItems
  '';

  meta = {
    description = "Unofficial Android and Windows (and Linux) application for Shikimori";
    homepage = "https://github.com/wheremyfiji/ShikiWatch";
    downloadPage = "https://github.com/wheremyfiji/ShikiWatch/releases";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ barsikus007 ];
  };
})
