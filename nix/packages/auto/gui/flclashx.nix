{
  lib,
  appimageTools,
  fetchurl,
  makeDesktopItem,
}:

appimageTools.wrapType2 rec {
  pname = "FlClashX";
  version = "0.2.1";

  src = fetchurl {
    url = "https://github.com/pluralplay/FlClashX/releases/download/v${version}/${pname}-${version}-linux-amd64.AppImage";
    hash = "sha256-r+1hXoVGZU8+1eK6l4hk2K+sHlKqAZbUhx0yrdDicaw=";
  };

  extraPkgs = pkgs: with pkgs; [ libepoxy ];

  extraInstallCommands = ''
    cp -r ${
      (makeDesktopItem {
        name = pname;
        exec = "${pname} %U";
        icon = pname;
        genericName = pname;
        desktopName = pname;
        type = "Application";
        comment = meta.description;
        categories = [ "Network" ];
        keywords = [
          "FlClashX"
          "Clash"
          "ClashMeta"
          "Proxy"
        ];
      })
    }/* $out
  '';

  meta = with lib; {
    description = "A fork of the multi-platform proxy client FlClash based on ClashMeta, simple and easy to use, open source and ad-free";
    homepage = "https://github.com/pluralplay/FlClashX";
    downloadPage = "https://github.com/pluralplay/FlClashX/releases";
    platforms = with platforms; lists.intersectLists x86_64 linux;
    license = with lib.licenses; [ gpl3Plus ];
    mainProgram = "FlClashX";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ barsikus007 ];
  };
}
