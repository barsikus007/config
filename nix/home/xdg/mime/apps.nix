{ lib, ... }:
{
  xdg = {
    #? find /run/current-system/sw/share/applications /etc/profiles/per-user/$USER/share/applications ~/.local/share/applications | grep --ignore-case <name>
    mimeApps.enable = true;
    mimeApps.defaultApplications = {
      "inode/directory" = [
        "org.kde.dolphin.desktop"
        "code.desktop"
        "mpv.desktop"
      ];
      "image/*" = "org.kde.gwenview.desktop";
      "video/*" = "mpv.desktop";
      "audio/*" = [
        "org.kde.elisa.desktop"
        "mpv.desktop"
      ];
      "application/zip" = "org.kde.ark.desktop";
      "application/x-msdownload" = "wine";
    }
    //
      lib.genAttrs
        [
          "application/xml"
          "application/json"
          "application/x-shellscript"
          "text/javascript"
          "application/javascript"
          # default for unknown (binary) and text
          "text/plain"
          "application/octet-stream"
          "application/x-zerosize"
        ]
        (key: [
          "org.kde.kate.desktop"
          "code.desktop"
          "org.kde.kwrite.desktop"
          "neovide.desktop"
          "nvim.desktop"
        ]);
    mimeApps.associations.removed = lib.genAttrs [
      "text/javascript"
      "application/javascript"
    ] (_: [ "writer.desktop" ]);
  };
}
