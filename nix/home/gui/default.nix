{
  programs.keepassxc = {
    enable = true;
    settings = {
      Browser = {
        Enabled = true;
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
