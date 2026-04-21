{
  dock = [
    "org.kde.dolphin"
    "org.wezfurlong.wezterm"
    "firefox"
    # "microsoft-edge"
    # "brave"
    "code"
    "com.ayugram.desktop"
    # "discord"
    "vesktop"
    # "dorion"
    "obsidian"
    "bcompare"
    "thunderbird"
  ];
  shortcuts = [
    {
      name = "Open Launcher";
      command = "anyrun";
      keys = "Mod+S";
    }
    {
      name = "Open Focused Window's PID in `btop`";
      command = "inspect-window";
      keys = "Mod+Ctrl+Grave"; # ? `
    }
    {
      name = "Capture Screen Region then Extract Text with OCR";
      command = "ocr-screen-region";
      keys = "Mod+Shift+T";
    }
  ];
}
