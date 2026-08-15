{ lib, pkgs, ... }@args:
let
  imageApps = args.imageApps or [ "org.kde.gwenview.desktop" ];
  videoApps = args.videoApps or [ "mpv.desktop" ];
  audioApps =
    args.audioApps or [
      "org.kde.elisa.desktop"
      "mpv.desktop"
    ];

  mimeXml = "${pkgs.shared-mime-info}/share/mime/packages/freedesktop.org.xml";
  mimeTypesUnder =
    prefix:
    let
      lines = lib.splitString "\n" (builtins.readFile mimeXml);
      decls = builtins.filter (l: lib.hasInfix ''<mime-type type="${prefix}/'' l) lines;
    in
    map (l: lib.head (lib.splitString ''"'' (lib.elemAt (lib.splitString ''type="'' l) 1))) decls;
in
{
  xdg.mimeApps.defaultApplications = lib.attrsets.mergeAttrsList [
    (lib.genAttrs (mimeTypesUnder "image") (_: imageApps))
    (lib.genAttrs (mimeTypesUnder "video") (_: videoApps))
    (lib.genAttrs (mimeTypesUnder "audio") (_: audioApps))
  ];
}
