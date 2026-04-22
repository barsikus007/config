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
    #? name is alphanumeric and -
    {
      name = "Open Launcher";
      command = "anyrun";
      keys = "Mod+S";
    }
    {
      name = "Open PID of Focused Window in btop";
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
