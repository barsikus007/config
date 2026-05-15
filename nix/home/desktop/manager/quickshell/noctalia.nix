{
  lib,
  config,
  inputs,
  options,
  ...
}:
#? https://github.com/noctalia-dev/noctalia-shell
let
  meta = import ../../meta.nix;
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.niri.settings = {
    spawn-at-startup = [ { command = [ "noctalia-shell" ]; } ];
    binds =
      with config.lib.niri.actions;
      let
        noctalia-ipc = spawn "noctalia-shell" "ipc" "call";
      in
      {
        "Mod+F1" = {
          hotkey-overlay.title = "Show Important Hotkeys";
          action = noctalia-ipc "plugin:keybind-cheatsheet" "toggle";
        };
        "Alt+Space" = {
          hotkey-overlay.title = "Toggle Application Launcher";
          action = noctalia-ipc "launcher" "toggle";
        };
        "Mod+Alt+I" = {
          hotkey-overlay.title = "Toggle Settings";
          action = noctalia-ipc "settings" "toggle";
        };
        "Mod+L" = {
          hotkey-overlay.title = "Lock Screen";
          action = noctalia-ipc "lockScreen" "lock";
          allow-when-locked = true;
        };
        "Ctrl+Alt+Delete" = {
          hotkey-overlay.title = "Toggle Power Menu";
          action = noctalia-ipc "sessionMenu" "toggle";
          allow-when-locked = true;
        };

        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action = noctalia-ipc "volume" "increase";
        };
        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action = noctalia-ipc "volume" "decrease";
        };
        "XF86AudioMute" = {
          allow-when-locked = true;
          action = noctalia-ipc "volume" "muteOutput";
        };
        "XF86AudioMicMute" = {
          allow-when-locked = true;
          action = noctalia-ipc "volume" "muteInput";
        };
        "Alt+XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action = noctalia-ipc "volume" "increaseInput";
        };
        "Alt+XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action = noctalia-ipc "volume" "decreaseInput";
        };
        "XF86MonBrightnessUp" = {
          allow-when-locked = true;
          action = noctalia-ipc "brightness" "increase";
        };
        "XF86MonBrightnessDown" = {
          allow-when-locked = true;
          action = noctalia-ipc "brightness" "decrease";
        };

        "Mod+V" = {
          hotkey-overlay.title = "Toggle Clipboard Manager";
          action = noctalia-ipc "launcher" "clipboard";
        };
        #? "Mod+Period"
        "Mod+Semicolon" = {
          hotkey-overlay.title = "Toggle Emoji Picker 🤓";
          action = noctalia-ipc "launcher" "emoji";
        };
      }
      // lib.attrsets.optionalAttrs config.custom.isAsus {
        "XF86Launch4" = {
          hotkey-overlay.title = "Asus: Cycle Power Profiles";
          action.spawn-sh = "noctalia-shell ipc call powerProfile cycle";
        };
        "Mod+Shift+S" = {
          hotkey-overlay.title = "Quick ScreenCapture";
          action.spawn-sh = "noctalia-shell ipc call plugin:screen-recorder toggle";
        };
      };
  };
  programs.noctalia-shell = {
    enable = true;
    settings = {
      #? https://docs.noctalia.dev/getting-started/nixos/#config-ref
      appLauncher = {
        overviewLayer = true;
        enableClipboardHistory = true;
        autoPasteClipboard = true;
        screenshotAnnotationTool = "satty -f -";
        terminalCommand = "wezterm start --always-new-process --";
      };
      bar = {
        density = "comfortable";
        position = "top";
        floating = true;
        widgets = {
          left = [
            {
              id = "ControlCenter";
              useDistroLogo = true;
            }
            {
              id = "SystemMonitor";
            }
            {
              id = "plugin:screen-recorder";
              defaultSettings = {
                copyToClipboard = true;
                frameRate = 144;
                videoCodec = "hevc";
                audioSource = "both";
              };
            }
            # TODO
            {
              id = "plugin:pomodoro";
            }
            {
              id = "plugin:kde-connect";
            }

            {
              id = "ActiveWindow";
              # id = "Taskbar";
              # showTitle = true;
            }
          ];
          center = [
            {
              id = "Workspace";
              showApplications = true;
            }
          ];
          right = [
            {
              id = "CustomButton";
              icon = "music-pin";
              leftClickExec = "dbus-send --type=method_call --dest=org.kde.plasma.browser_integration /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Raise";
            }
            {
              id = "MediaMini";
              showVisualizer = true;
            }
            {
              id = "Tray";
              # drawerEnabled = false;
            }
            {
              id = "plugin:privacy-indicator";
              defaultSettings.hideInactive = false;
            }
            {
              id = "NotificationHistory";
            }
            {
              id = "Network";
            }
            {
              id = "Brightness";
              displayMode = "alwaysShow";
            }
            {
              id = "Volume";
              displayMode = "alwaysShow";
            }
            {
              id = "Battery";
              displayMode = "graphic";
              alwaysShowPercentage = true;
              warningThreshold = 30;
              showNoctaliaPerformance = true;
              showPowerProfiles = true;
            }
            {
              id = "KeyboardLayout";
              showIcon = false;
            }
            (
              {
                id = "Clock";
                formatHorizontal = "yyyy-MM-dd HH:mm:ss";
                useCustomFont = true;
              }
              // lib.attrsets.optionalAttrs (options ? stylix) {
                customFont = config.stylix.fonts.monospace.name;
              }
            )
          ];
        };
      };
      brightness.enableDdcSupport = true;
      dock = {
        dockType = "attached";
        showDockIndicator = true;
        indicatorThickness = 6;
        showLauncherIcon = true;
        launcherPosition = "start";
        launcherUseDistroLogo = true;
        pinnedStatic = true;
        inactiveIndicators = true;
        pinnedApps = meta.dock;
      };
      general = {
        showScreenCorners = true;
        forceBlackScreenCorners = true;
        lockScreenAnimations = true;
        autoStartAuth = true;
        # TODO: breaks fprintd auth if authorized with pass?
        allowPasswordWithFprintd = true;
      };
      location = {
        name = "Moscow";
        firstDayOfWeek = 1;
        monthBeforeDay = false;
        use12hourFormat = false;
      };
      plugins.autoUpdate = true;
      idle =
        let
          noctalia_ipc_call = "${lib.getExe config.programs.noctalia-shell.package} ipc call";
          is_locked =
            builtins.replaceStrings [ ''"'' ] [ ''\"'' ]
              ''[ $(loginctl show-session $XDG_SESSION_ID -p LockedHint --value) == "yes" ]'';
          power_off_monitors_cmd = "${lib.getExe config.programs.niri.package} msg action power-off-monitors";

          lockscreen_command = ''{"name":"Lockscreen turn off displays","timeout":30,"command":"${is_locked} && ${power_off_monitors_cmd}"}'';
          dim_command = ''{"name":"Dim monitors","timeout":300,"command":"${noctalia_ipc_call} brightness set 0","resumeCommand":"${noctalia_ipc_call} brightness set 100"}'';
        in
        {
          enabled = true;
          screenOffTimeout = 600;
          lockTimeout = 900;
          suspendTimeout = 0;
          customCommands = "[${lockscreen_command},${dim_command}]";
        };
    };
    plugins = {
      sources = [
        {
          enabled = true;
          name = "Official Noctalia Plugins";
          url = "https://github.com/noctalia-dev/noctalia-plugins";
        }
      ];
      states = {
        keybind-cheatsheet = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
        niri-overview-launcher = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
        privacy-indicator = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
        screen-recorder = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
        kde-connect = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
        polkit-agent = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };

        #? appLauncher
        currency-exchange = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
        kaomoji-provider = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };

        #? bar: https://noctalia.dev/plugins/pomodoro/
        pomodoro = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
      };
      version = 2;
    };
  };
  #? noctalia have own polkit now
  services.polkit-gnome.enable = false;
  #? screenshot annotation for clipboard history
  programs.satty.enable = true;
}
