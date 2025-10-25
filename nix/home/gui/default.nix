{ lib, ... }:
{
  xdg = {
    #? ls /run/current-system/sw/share/applications /etc/profiles/per-user/$(id -n -u)/share/applications ~/.nix-profile/share/applications | grep <name>
    mimeApps.enable = true;
    mimeApps.defaultApplications =
      lib.genAttrs
        [
          # default for unknown (binary) and text
          "text/plain"
          "application/octet-stream"
          "application/x-zerosize"
        ]
        (key: [
          "org.kde.kate.desktop"
          # "org.kde.kwrite.desktop"
          "code.desktop"
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
}
