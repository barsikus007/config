{ lib, ... }:
{
  xdg = {
    #? ls /run/current-system/sw/share/applications /etc/profiles/per-user/$(id -n -u)/share/applications ~/.nix-profile/share/applications ~/.local/share/applications | grep <name>
    mimeApps.enable = true;
    mimeApps.defaultApplications = {
      "inode/directory" = [
        "org.kde.dolphin.desktop"
        "code.desktop"
      ];
      "image/*" = "org.kde.gwenview.desktop";
      "video/*" = "mpv.desktop";
      "audio/*" = [
        "org.kde.elisa.desktop"
        "mpv.desktop"
      ];
    }
    //
      lib.genAttrs
        [
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
    userDirs.enable = true;
  };

  programs.keepassxc = {
    enable = true;
    settings = {
      Browser = {
        Enabled = true;
        BestMatchOnly = true;
        AlwaysAllowAccess = true;
      };
      GUI = {
        # AdvancedSettings = true;
        # ApplicationTheme = "dark";
        # CompactMode = true;
        # HidePasswords = true;
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
    };
  };
  services.copyq.enable = true;
  # # xdg.configFile."copyq/copyq.conf".source =
  #   config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/copyq/copyq.conf";
}
