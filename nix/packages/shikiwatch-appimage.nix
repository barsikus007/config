{
  lib,
  appimageTools,
  fetchurl,
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
  extraInstallCommands = ''
    cp -r ${(makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = pname;
      type = "Application";
      comment = meta.description;
      categories = [
        "AudioVideo"
        "Video"
        "Network"
      ];
    })}/* $out
  '';

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
