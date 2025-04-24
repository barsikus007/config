{ ... }:
{
  # TODO: KDE https://wiki.nixos.org/wiki/KDE#GNOME_desktop_integration
  # https://github.com/nix-community/plasma-manager
  # https://nix-community.github.io/plasma-manager/options.xhtml
  programs.plasma = {
    enable = true;
    overrideConfig = true;

    # hotkeys.commands."launch-konsole" = {
    #   name = "Launch Ghostty";
    #   key = "Meta+Alt+T";
    #   command = "ghostty";
    # };
    # kscreenlocker = {
    #   lockOnResume = true;
    #   timeout = 10;
    # };
    # powerdevil.battery.whenLaptopLidClosed = "hibernate";

    workspace = {
      # clickItemTo = "open"; # breaks type to search func in dolphin
      lookAndFeel = "org.kde.breezedark.desktop";
    };

    fonts = {
      # general = {
      #   family = "Cascadia Mono NF";
      #   pointSize = 10;
      #   weight = 350;
      # };
      fixedWidth = {
        family = "Cascadia Mono NF";
        pointSize = 10;
      };
    };

    panels = [
      # Windows-like panel at the bottom
      {
        # location = "bottom";
        floating = true;
        widgets = [
          # }
          # Or you can configure the widgets by adding the widget-specific options for it.
          # See modules/widgets for supported widgets and options for these widgets.
          # For example:
          {
            kickoff.icon = "nix-snowflake";
          }
          "org.kde.plasma.pager"
          # Adding configuration to the widgets can also for example be used to
          # pin apps to the task-manager, which this example illustrates by
          # pinning dolphin and konsole to the task-manager by default with widget-specific options.
          {
            iconTasks = {
              launchers = [
                # TODO not linked to anything
                "applications:org.kde.dolphin.desktop"
                "applications:com.mitchellh.ghostty.desktop"
                "applications:microsoft-edge.desktop"
                "applications:code.desktop"
                "applications:com.ayugram.desktop.desktop"
                "applications:vesktop.desktop"
                # todo autolaunch
                "applications:nekoray.desktop"
              ];
            };
          }
          # If no configuration is needed, specifying only the name of the
          # widget will add them with the default configuration.
          "org.kde.plasma.marginsseparator"
          {
            plasmusicToolbar = {
              panelIcon = {
                albumCover = {
                  fallbackToIcon = true;
                  useAsIcon = true;
                  # radius = 8; # default
                  radius = 25;
                };
              };
              songText = {
                # displayInSeparateLines = true;  # breaks buttons layout
                scrolling = {
                  behavior = "scrollOnHover";
                };
              };
            };
          }
          {
            systemMonitor = {
              title = "Memory Usage";
              displayStyle = "org.kde.ksysguard.linechart";
              sensors = [
                {
                  name = "memory/physical/used";
                  color = "61,174,233";
                  label = "RAM %";
                }
              ];
              totalSensors = [ "memory/physical/usedPercent" ];
              textOnlySensors = [ "memory/physical/total" ];
            };
          }
          {
            systemMonitor = {
              title = "CPU Usage";
              displayStyle = "org.kde.ksysguard.linechart";
              sensors = [
                {
                  name = "cpu/all/used";
                  color = "233,120,61";
                  label = "CPU %";
                }
              ];
              totalSensors = [ "cpu/all/usage" ];
              textOnlySensors = [ "memory/physical/total" ];
            };
          }
          # If you need configuration for your widget, instead of specifying the
          # the keys and values directly using the config attribute as shown
          # above, plasma-manager also provides some higher-level interfaces for
          # configuring the widgets. See modules/widgets for supported widgets
          # and options for these widgets. The widgets below shows two examples
          # of usage, one where we add a digital clock, setting 12h time and
          # first day of the week to Sunday and another adding a systray with
          # some modifications in which entries to show.
          {
            systemTray.items = {
              shown = [
                "org.kde.plasma.volume"
                "org.kde.plasma.battery"
                "org.kde.plasma.brightness"
                "org.kde.plasma.bluetooth"
                "org.kde.plasma.networkmanagement"
                "org.kde.plasma.keyboardlayout"
              ];
              # org.kde.plasma.cameraindicator,    org.kde.plasma.devicenotifier
              # org.kde.plasma.manage-inputmethod, org.kde.plasma.notifications, org.kde.plasma.keyboardindicator
              hidden = [
                "org.kde.kscreen"
                "org.kde.plasma.clipboard"
                "org.kde.plasma.mediacontroller"
                "org.kde.plasma.keyboardindicator"
              ];
            };
          }
          {
            digitalClock = {
              date.format = "isoDate";
              time.showSeconds = "always";
              calendar.showWeekNumbers = true;
            };
          }
          "org.kde.plasma.showdesktop"
        ];
      }
    ];

    # ETO PIZDA
    input.touchpads = [
      {
        vendorId = "1267";
        productId = "12440";
        name = "ELAN1201:00 04F3:3098 Touchpad";
        naturalScroll = true;
      }
    ];

    configFile.kxkbrc = {
      Layout = {
        DisplayNames = "EN,РУ";
        LayoutList = "us,ru";
        Options = "grp:lalt_lshift_toggle";
        ResetOldOptions = true;
        Use = true;
        VariantList = ",";
      };
    };
    shortcuts = {
      "KDE Keyboard Layout Switcher" = {
        "Switch to Next Keyboard Layout" = "Meta+Space";
      };
      "services/systemsettings.desktop" = {
        "_launch" = "Meta+I";
      };
      "kwin" = {
        "Overview" = "Meta+Tab";
      };
      "services/org.kde.konsole.desktop" = {
        "_launch" = "none";
      };
      "services/com.mitchellh.ghostty.desktop" = {
        "_launch" = "Ctrl+Alt+T";
      };
      "org_kde_powerdevil" = {
        "powerProfile" = [
          "Battery"
          "Launch (4)"
          "Meta+B,Battery"
          "Meta+B,Switch Power Profile"
        ];
      };
    };

    # windows.allowWindowsToRememberPositions = true;

    kwin.virtualDesktops = {
      rows = 1;
      names = [
        "Desktop 1"
        "Desktop 2"
      ];
    };

    configFile = {
      "kdeglobals"."General"."TerminalApplication" = "ghostty";
      "kdeglobals"."General"."TerminalService" = "com.mitchellh.ghostty.desktop";

      "kwinrc"."Windows"."FocusStealingPreventionLevel" = 2;
      # "kwinrc"."Windows"."FocusStealingPreventionLevel" = 3;
      # "kwinrc"."Windows"."FocusStealingPreventionLevel" = 4;
      # "kwinrc"."Windows"."FocusStealingPreventionLevel" = 5;
      "plasmaparc"."General"."RaiseMaximumVolume" = true;

      "spectaclerc"."General"."autoSaveImage" = true;
      "spectaclerc"."General"."clipboardGroup" = "PostScreenshotCopyImage";
      "spectaclerc"."General"."launchAction" = "UseLastUsedCapturemode";
      "spectaclerc"."GuiConfig"."captureMode" = 0;
      "spectaclerc"."GuiConfig"."quitAfterSaveCopyExport" = true;
      "spectaclerc"."ImageSave"."translatedScreenshotsFolder" = "Screenshots";
      "spectaclerc"."VideoSave"."translatedScreencastsFolder" = "Screencasts";

      "klipperrc"."General"."IgnoreImages" = false;
      # "klipperrc"."General"."IgnoreSelection" = false;
      "klipperrc"."General"."MaxClipItems" = 50;
      # "klipperrc"."General"."SelectionTextOnly" = false;
      # "klipperrc"."General"."SyncClipboards" = true;

      # "dolphinrc"."DetailsMode"."PreviewSize" = 16;
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
      # "kdeglobals"."KFileDialog Settings"."Show hidden files" = false;
      # "kdeglobals"."KFileDialog Settings"."Sort by" = "Name";
      # "kdeglobals"."KFileDialog Settings"."Sort directories first" = true;
      # "kdeglobals"."KFileDialog Settings"."Sort hidden files last" = false;
      # "kdeglobals"."KFileDialog Settings"."Sort reversed" = false;
      # "kdeglobals"."KFileDialog Settings"."View Style" = "DetailTree";

      # "kiorc"."Confirmations"."ConfirmDelete" = true;
      # "kiorc"."Executable scripts"."behaviourOnLaunch" = "execute";

    };
    dataFile = {
      # "dolphin/view_properties/global/.directory"."Dolphin"."ViewMode" = 1;
      # "dolphin/view_properties/global/.directory"."Settings"."HiddenFilesShown" = true;
    };

  };
  home.file.".face.icon".source = builtins.fetchurl {
    url = "https://github.com/barsikus007.png";
    sha256 = "0ffhgshb652pcq35jc9gqzp576ss0kbz031rxylp6k8gvz213yc9";
  };
}
