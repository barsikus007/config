{ pkgs, ... }:
{
  programs.keepassxc = {
    enable = true;
    package = pkgs.flakePackages.keepassxc;
    settings = {
      General = {
        ConfigVersion = 2;
        UpdateCheckMessageShown = true;
      };
      Browser = {
        Enabled = true;
        BestMatchOnly = true;
        AlwaysAllowAccess = true;
        UpdateBinaryPath = false;
      };
      GUI = {
        AdvancedSettings = true;
        CheckForUpdates = false;
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
      Security.IconDownloadFallback = true;
    };
  };
  xdg.configFile."keepassxc/keepassxc.ini".mutable = true;
}
