{ lib, pkgs, ... }@args:
let
  imageApps = if args ? imageApps then args.imageApps else [ "org.kde.gwenview.desktop" ];
  videoApps = if args ? videoApps then args.videoApps else [ "mpv.desktop" ];
  audioApps =
    if args ? audioApps then
      args.audioApps
    else
      [
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
