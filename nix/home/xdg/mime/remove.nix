{ pkgs, config, ... }:
let
  #! KDE "Open With" lists every app that self-declares a mimetype, ignoring Hidden= and
  #! mimeapps removedAssociations; only dropping the MimeType= line removes it there
  #? derive each entry from its own package (nothing hardcoded) into XDG_DATA_HOME, where it
  #? wins by storage-id. umpv keeps its own NoDisplay=true, so it also stays out of the launcher
  dropMimeType = pkg: file: {
    name = "applications/${file}";
    value.source = pkgs.runCommand file { } ''
      grep -v '^MimeType=' ${pkg}/share/applications/${file} > $out
    '';
  };
  unassociatedEntries = [
    (dropMimeType config.programs.mpv.package "umpv.desktop") # nonfunctional wrapper bundled with mpv
  ];
in
{
  xdg.dataFile = builtins.listToAttrs unassociatedEntries;
}
