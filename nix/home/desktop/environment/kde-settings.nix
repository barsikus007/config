{ inputs, ... }:
#? non-specific KDE settings, used by KDE apps even without KDE itself
{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  programs.plasma = {
    enable = true;
    overrideConfig = true;

    configFile = {
      "kdeglobals"."General"."TerminalApplication" = "wezterm";
      "kdeglobals"."General"."TerminalService" = "org.wezfurlong.wezterm.desktop";
      "kdeglobals"."Shortcuts"."Redo" = "Ctrl+Y";
      # "kdeglobals"."PreviewSettings"."EnableRemoteFolderThumbnail" = true;
      "kdeglobals"."PreviewSettings"."MaximumRemoteSize" = 1073741824; # 1 GiB

      #? kde file portal settings
      # "dolphinrc"."KFileDialog Settings"."Places Icons Auto-resize" = false;
      # "dolphinrc"."KFileDialog Settings"."Places Icons Static Size" = 22;

      # "kdeglobals"."KFileDialog Settings"."Allow Expansion" = false;
      # "kdeglobals"."KFileDialog Settings"."Automatically select filename extension" = true;
      # "kdeglobals"."KFileDialog Settings"."Breadcrumb Navigation" = true;
      # "kdeglobals"."KFileDialog Settings"."Decoration position" = 2;
      # "kdeglobals"."KFileDialog Settings"."LocationCombo Completionmode" = 5;
      # "kdeglobals"."KFileDialog Settings"."PathCombo Completionmode" = 5;
      # "kdeglobals"."KFileDialog Settings"."Show Bookmarks" = false;
      # "kdeglobals"."KFileDialog Settings"."Show Full Path" = false;
      # "kdeglobals"."KFileDialog Settings"."Show Inline Previews" = true;
      # "kdeglobals"."KFileDialog Settings"."Show Preview" = false;
      # "kdeglobals"."KFileDialog Settings"."Show Speedbar" = true;
      "kdeglobals"."KFileDialog Settings"."Show hidden files" = true;
      # "kdeglobals"."KFileDialog Settings"."Sort by" = "Name";
      # "kdeglobals"."KFileDialog Settings"."Sort directories first" = true;
      # "kdeglobals"."KFileDialog Settings"."Sort hidden files last" = false;
      # "kdeglobals"."KFileDialog Settings"."Sort reversed" = false;
      # "kdeglobals"."KFileDialog Settings"."View Style" = "DetailTree";

      "dolphinrc"."General"."ShowFullPath" = true;
      "dolphinrc"."General"."BrowseThroughArchives" = true;
      # TODO: "dolphinrc"."UiSettings"."ColorScheme" = "";
      "dolphinrc"."UiSettings"."ColorScheme" = "BreezeDark";
      "dolphinrc"."DetailsMode"."PreviewSize" = 16;

      # "kiorc"."Confirmations"."ConfirmDelete" = true;
      # "kiorc"."Executable scripts"."behaviourOnLaunch" = "execute";
    };
    dataFile = {
      # "dolphin/view_properties/global/.directory"."Dolphin"."ViewMode" = 1;
      # "dolphin/view_properties/global/.directory"."Settings"."HiddenFilesShown" = true;
    };
  };
}
