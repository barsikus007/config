{ lib, ... }@args:
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
in
{
  xdg.mimeApps.defaultApplications =
    let
      generateGlobAssociations =
        type: sha256: application:
        let
          #? https://www.iana.org/assignments/media-types/media-types.xhtml#image
          csv = builtins.fetchurl {
            url = "https://www.iana.org/assignments/media-types/${type}.csv";
            inherit sha256;
          };

          mimeTypes = builtins.filter (s: s != "") (
            map (s: builtins.elemAt (lib.splitString "," s) 1) (
              builtins.filter (s: !lib.hasInfix "DEPRECATED" s) (
                lib.lists.drop 1 (lib.lists.dropEnd 1 (lib.strings.splitString "\r\n" (builtins.readFile csv)))
              )
            )
          );

        in
        lib.genAttrs mimeTypes (_: application);
    in
    lib.attrsets.mergeAttrsList [
      (generateGlobAssociations "image" "sha256-lGrLRjIeJQxljR4TU2NJbXlA7oPyPfnSuvN2D5GXyLw=" imageApps)
      (generateGlobAssociations "video" "sha256-tjnyMpRhru4Rnghars3xGx3ymrD/hGBV0GpnTZmOnHQ=" videoApps)
      (generateGlobAssociations "audio" "sha256-4yvqIbfwCQewIV257hUld9eB2XTNndBCOoLtqwwM8hc=" audioApps)
    ];
}
