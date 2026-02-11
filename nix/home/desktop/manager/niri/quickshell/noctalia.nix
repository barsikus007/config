{ pkgs, inputs, ... }:
#? https://github.com/noctalia-dev/noctalia-shell
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  systemd.user.services.noctalia-shell.Service.Environment = [
    # "QT_QPA_PLATFORM=wayland;xcb"
    "QT_QPA_PLATFORMTHEME=qt6ct"
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
            # TODO
            {
              id = "plugin:screen-recorder";
            }
            {
              id = "plugin:pomodoro";
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
            }
            {
              id = "Volume";
            }
            {
              id = "KeyboardLayout";
              showIcon = false;
            }
            {
              id = "plugin:noctalia-supergfxctl";
            }
            {
              id = "PowerProfile";
            }
            {
              id = "Battery";
              alwaysShowPercentage = true;
              warningThreshold = 30;
              showNoctaliaPerformance = true;
              showPowerProfiles = true;
            }
            {
              id = "Clock";
              formatHorizontal = "yyyy-MM-dd HH:mm:ss";
              useMonospacedFont = true;
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

        #? bar
        noctalia-supergfxctl = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
        #? https://noctalia.dev/plugins/pomodoro/
        pomodoro = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
      };
      version = 2;
    };
  };
  programs.satty.enable = true;
  services.swayidle = {
    enable = true;
    timeouts = with pkgs; [
      {
        timeout = 10 * 60;
        command = "${lib.getExe niri} msg action power-off-monitors";
      }
      {
        timeout = 15 * 60;
        command = "${
          lib.getExe inputs.noctalia.packages.${stdenv.hostPlatform.system}.default
        } ipc call lockScreen lock";
      }
    ];
  };
}
