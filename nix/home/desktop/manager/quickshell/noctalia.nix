{
  pkgs,
  config,
  inputs,
  ...
}:
#? https://github.com/noctalia-dev/noctalia-shell
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  systemd.user.services.noctalia-shell.Service.Environment = [
    # "QT_QPA_PLATFORM=wayland;xcb"
    # "QT_QPA_PLATFORMTHEME=qt6ct"
    #? fix some icons
    "QT_QPA_PLATFORMTHEME=gtk3"
    # "QT_AUTO_SCREEN_SCALE_FACTOR=1"
  ];
  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
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
              # id = "ActiveWindow";
              id = "Taskbar";
              showTitle = true;
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
              id = "PowerProfile";
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
            {
              id = "Clock";
              formatHorizontal = "yyyy-MM-dd HH:mm:ss";
              useCustomFont = true;
              customFont = config.stylix.fonts.monospace.name;
            }
          ];
        };
      };
      dock = {
        pinnedStatic = true;
        inactiveIndicators = true;
        pinnedApps = [
          "org.kde.dolphin"
          "org.wezfurlong.wezterm"
          "firefox"
          # "microsoft-edge"
          "code"
          "com.ayugram.desktop"
          # "discord"
          "vesktop"
          # "dorion"
          "obsidian"
          "bcompare"
          "thunderbird"
        ];
      };
      general = {
        avatarImage = "~/.face.icon";
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
  #? screenshot annotation for clipboard history
  programs.satty.enable = true;
  services.hypridle = {
    enable = true;
    settings =
      with pkgs;
      let
        lock_cmd = "${
          lib.getExe inputs.noctalia.packages.${stdenv.hostPlatform.system}.default
        } ipc call lockScreen lock";
        power_off_monitors_cmd = "${lib.getExe niri} msg action power-off-monitors";
        is_locked = ''[ $(loginctl show-session $XDG_SESSION_ID -p LockedHint --value) == "yes" ]'';
      in
      {
        general = {
          inherit lock_cmd;
        };
        listener = [
          {
            timeout = 30;
            on-timeout = "${is_locked} && ${power_off_monitors_cmd}";
          }
          {
            timeout = 5 * 60;
            on-timeout = "${is_locked} || ${lib.getExe brightnessctl} -s set 10";
            on-resume = "${is_locked} || ${lib.getExe brightnessctl} -r";
          }
          {
            timeout = 10 * 60;
            on-timeout = "${is_locked} || ${power_off_monitors_cmd}";
          }
          {
            timeout = 15 * 60;
            on-timeout = "${is_locked} || ${lib.getExe brightnessctl} -r && loginctl lock-session";
          }
        ];
      };
  };
}
