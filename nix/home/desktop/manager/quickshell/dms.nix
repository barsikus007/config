{
  lib,
  config,
  inputs,
  flakePath,
  ...
}:
let
  meta = import ../../meta.nix;
in
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
  ];
  xdg.configFile."niri/dms/".source =
    config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/niri/dms/";
  xdg.configFile.niri-config-dms.target = lib.mkForce "niri/nix-generated-config.kdl";
  #? initial
  # home.activation = {
  #   dmsImperative = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #     dms setup alttab
  #     dms setup binds
  #     dms setup colors
  #     dms setup cursor
  #     dms setup layout
  #     dms setup outputs
  #     dms setup windowrules
  #   '';
  # };
  programs.dank-material-shell = {
    enable = true;
    systemd.enable = true;
    niri = {
      includes = {
        filesToInclude = [
          "alttab"
          "binds"
          "colors"
          # "layout"
          "outputs"
          "wpblur"

          # "cursor"
          "windowrules"
        ];
      };
    };
    session.pinnedApps = meta.dock;
    settings = {
      workspaceNameIcons = {
        social = {
          type = "icon";
          value = "chat";
        };
        games = {
          type = "icon";
          value = "webhook";
        };
      };
      showSeconds = true;
      clockDateFormat = "yyyy-MM-dd";
      weatherEnabled = false;
      launcherLogoMode = "os";
      launcherLogoColorOverride = "#5277c3";
      dockOpenOnOverview = true;
      dockLauncherEnabled = true;
      osdAlwaysShowValue = true;
      osdPosition = 0;
      #! it appears on forwards
      # osdMediaPlaybackEnabled = true;
      osdPowerProfileEnabled = true;
      barConfigs = [
        {
          enabled = true;
          id = "default";
          name = "Main Bar";
          position = 0;
          leftWidgets = [
            "launcherButton"
            "cpuUsage"
            "memUsage"
            "focusedWindow"
          ];
          centerWidgets = [
            "workspaceSwitcher"
          ];
          rightWidgets = [
            "music"
            "systemTray"
            "notificationButton"
            "clipboard"
            "privacyIndicator"
            {
              id = "keyboard_layout_name";
              keyboardLayoutNameCompactMode = true;
            }
            {
              id = "controlCenterButton";
              enabled = true;
              showAudioPercent = true;
              showBrightnessIcon = true;
              showBrightnessPercent = true;
              showMicIcon = true;
              showMicPercent = true;
              showBatteryIcon = true;
              showPrinterIcon = true;
            }
            "battery"
            "clock"
          ];
          widgetPadding = 8;
        }
      ];
      showWorkspaceIndex = true;
      showWorkspaceApps = true;
      maxWorkspaceIcons = 9;
      acMonitorTimeout = 600;
      acLockTimeout = 900;
      lockBeforeSuspend = true;
      #! cause fprint is fucked up in dms (it is ignored btw)
      # enableFprint = true;
      clipboardEnterToPaste = true;
    };
    # clipboardSettings = { };
  };
  programs.niri.settings = {
    binds =
      with config.lib.niri.actions;
      let
        dms-ipc = spawn "dms" "ipc";
      in
      {
        "Alt+Space" = {
          action = dms-ipc "spotlight" "toggle";
          hotkey-overlay.title = "Toggle Application Launcher";
        };
        "Mod+N" = {
          action = dms-ipc "notifications" "toggle";
          hotkey-overlay.title = "Toggle Notification Center";
        };
        "Mod+Alt+I" = {
          action = dms-ipc "settings" "toggle";
          hotkey-overlay.title = "Toggle Settings";
        };
        "Mod+L" = {
          action = dms-ipc "lock" "lock";
          hotkey-overlay.title = "Lock Screen";
          allow-when-locked = true;
        };
        "Ctrl+Alt+Delete" = {
          action = dms-ipc "powermenu" "toggle";
          hotkey-overlay.title = "Toggle Power Menu";
          allow-when-locked = true;
        };
        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action = dms-ipc "audio" "increment" "5";
        };
        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action = dms-ipc "audio" "decrement" "5";
        };
        "XF86AudioMute" = {
          allow-when-locked = true;
          action = dms-ipc "audio" "mute";
        };
        "XF86AudioMicMute" = {
          allow-when-locked = true;
          action = dms-ipc "audio" "micmute";
        };
        "XF86MonBrightnessUp" = {
          allow-when-locked = true;
          action = dms-ipc "brightness" "increment" "10";
        };
        "XF86MonBrightnessDown" = {
          allow-when-locked = true;
          action = dms-ipc "brightness" "decrement" "10";
        };
        "Mod+V" = {
          action = dms-ipc "clipboard" "toggle";
          hotkey-overlay.title = "Toggle Clipboard Manager";
        };
        "Ctrl+Shift+Escape" = {
          action = dms-ipc "processlist" "toggle";
          hotkey-overlay.title = "Toggle Process List";
        };
      };
  };
}
