{
  lib,
  appimageTools,
  fetchurl,
  copyDesktopItems,
  makeDesktopItem,
}:

appimageTools.wrapType2 rec {
  pname = "ShikiWatch";
  version = "0.12.0";

  src = fetchurl {
    url = "https://github.com/wheremyfiji/ShikiWatch/releases/download/v${version}/ShikiWatch-${version}-linux-amd64.AppImage";
    hash = "sha256-DNLQG3N2Ni8kTsvO1RhRQiaAvPHGqhiRUgDWViwFbCc=";
  };

  # GDK_BACKEND=x11
  nativeBuildInputs = [ copyDesktopItems ];

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = pname;
      type = "Applications";
      comment = meta.description;
      categories = [
        "Video"
        "Network"
      ];
    })
  ];

  meta = with lib; {
    description = "Unofficial Android and Windows (and Linux) application for Shikimori";
    homepage = "https://github.com/wheremyfiji/ShikiWatch";
    downloadPage = "https://github.com/wheremyfiji/ShikiWatch/releases";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ barsikus007 ];
    platforms = [ "x86_64-linux" ];
  };
}
