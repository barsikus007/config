{
  lib,
  self,
  pkgs,
  ...
}:
let
  #! packages ship desktop entries that pollute dolphin "Open With" (mpv ships umpv)
  #! KDE ignores Hidden= and mimeapps removedAssociations for self-declared mimetypes,
  #! but a valid same-name entry in XDG_DATA_HOME wins by storage-id
  #? so redeclaring it with an empty MimeType de-associates it from every type, no package edit
  neutralizedApplications = [
    "umpv" # nonfunctional one-instance wrapper bundled with mpv
  ];
in
{
  #? handlr redirects URLs to some apps and only then to browsers
  # TODO: use as xdg-utils replacement
  home.packages = with pkgs; [ handlr-regex ];

  xdg = {
    userDirs.enable = true;
    desktopEntries = lib.genAttrs neutralizedApplications (name: {
      inherit name;
      exec = "${name} %U";
      noDisplay = true;
      mimeType = [ ];
    });

    #? find /run/current-system/sw/share/applications /etc/profiles/per-user/$USER/share/applications ~/.local/share/applications | grep -i <name>
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

  programs.keepassxc = {
    enable = true;
    package = self.packages.${pkgs.stdenv.hostPlatform.system}.keepassxc;
    settings = {
      Browser = {
        Enabled = true;
        BestMatchOnly = true;
        AlwaysAllowAccess = true;
        UpdateBinaryPath = false;
      };
      GUI = {
        AdvancedSettings = true;
        ColorPasswords = true;
        CompactMode = true;
        MinimizeOnClose = true;
        MinimizeOnStartup = true;
        ShowTrayIcon = true;
        TrayIconAppearance = "monochrome-light";
      };
      PasswordGenerator = {
        Length = 32;
        SpecialChars = false;
      };
      SSHAgent.Enabled = true;
      FdoSecrets.Enabled = true;
    };
  };
  # xdg.configFile."keepassxc/keepassxc.ini".source =
  #   config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/keepassxc/keepassxc.ini";

  # services.copyq.enable = true;
  # # xdg.configFile."copyq/copyq.conf".source =
  #   config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/copyq/copyq.conf";
}
