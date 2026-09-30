{
  lib,
  fetchurl,
  appimageTools,
  copyDesktopItems,
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
    postExtract = ''
      chmod +x $out/usr/bin/lib/crashpad_handler
      ${lib.getExe python3} ${./patch-flutter-lcxx.py} $out/usr/bin/lib/libflutter_linux_gtk.so
    '';
  };
in
appimageTools.wrapAppImage (finalAttrs: {
  inherit pname version src;
  nativeBuildInputs = [ copyDesktopItems ];
  contents = appimageContents;
  # GDK_BACKEND=x11
  desktopItems = [
    (makeDesktopItem {
      name = finalAttrs.pname;
      categories = [
        "AudioVideo"
        "Video"
        "Network"
      ];
      comment = finalAttrs.meta.description;
      desktopName = finalAttrs.pname;
      exec = finalAttrs.pname;
      icon = finalAttrs.pname;
      type = "Application";
    })
  ];
  extraInstallCommands = ''
    install -D --mode=444 ${appimageContents}/usr/share/icons/hicolor/256x256/apps/ShikiWatch.png \
      $out/share/icons/hicolor/256x256/apps/ShikiWatch.png
    copyDesktopItems
  '';
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
  meta = {
    description = "Unofficial Android and Windows (and Linux) application for Shikimori";
    homepage = "https://github.com/wheremyfiji/ShikiWatch";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ barsikus007 ];
    platforms = [ "x86_64-linux" ];
    downloadPage = "https://github.com/wheremyfiji/ShikiWatch/releases";
  };
})
