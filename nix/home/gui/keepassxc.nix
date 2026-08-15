{ pkgs, self, ... }:
{
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
}
