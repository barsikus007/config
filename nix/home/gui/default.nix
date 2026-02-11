{
  lib,
  self,
  pkgs,
  ...
}:
{
  xdg = {
    #? \command ls /run/current-system/sw/share/applications /etc/profiles/per-user/$(id -n -u)/share/applications ~/.local/share/applications | grep <name>
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
    package = self.packages.${pkgs.stdenv.hostPlatform.system}.gui.keepassxc;
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
