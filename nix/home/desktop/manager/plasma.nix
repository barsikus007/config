{
  lib,
  pkgs,
  config,
  ...
}:
let
  meta = import ../meta.nix;
in
{
  imports = [
    ../.
    ../environment/kde-settings.nix
  ];

  #? https://github.com/nix-community/plasma-manager
  #? https://nix-community.github.io/plasma-manager/options.xhtml
  programs.plasma = {
    hotkeys.commands = {
      "search" = {
        name = "Open Search";
        key = "Meta+S";
        command = "anyrun";
      };
      "inspect-window" = {
        name = "Open Current Window in btop";
        key = "Meta+Ctrl+`";
        command = "inspect-window";
      };
      "ocr-screen-region" = {
        name = "Capture Screen Region then Extract Text with OCR";
        key = "Meta+Shift+T";
        command = "ocr-screen-region";
      };
    }
    // lib.attrsets.optionalAttrs config.programs.rofi.enable {
      "rofi" = {
        name = "chuvak eto rofis";
        key = "Ctrl+Alt+Space";
        # TODO https://github.com/svenstaro/rofi-calc/issues/33
        command = "rofi -show combi -show-icons";
      };
      #! no other way vi klipper https://bugs.kde.org/show_bug.cgi?id=427214
      # TODO disable klipper
      # TODO pins https://github.com/sentriz/cliphist/issues/23
      # TODO css big images
      # TODO css split text
      # TODO cancel on esc
      # TODO appear under cursor or better - above focus
      "rofi-cb" = {
        name = "chuvak eto rofis-cb";
        key = "Ctrl+Meta+V";
        #? https://github.com/sentriz/cliphist/issues/111
        command = "zsh -c \"rofi -modi clipboard:cliphist-rofi-img -show clipboard -show-icons && ${pkgs.ydotool} key 29:1 47:1 47:0 29:0\"";
      };
    }
    // lib.attrsets.optionalAttrs config.custom.isAsus {
      "laptop-button-rog" = {
        name = "Laptop ROG Button";
        key = "Launch (1)";
        command = "zsh -c asus_anime_demo_toggle";
      };
      #? done by plasma natively now
      # "laptop-button-f5" = {
      #   name = "Laptop F5 Button";
      #   key = "Launch (4)";
      #   command = "zsh -c asus_profile_toggle";
      # };
      # TODO: start gpu-screen-record
      # "laptop-button-f6" = {
      #   name = "Laptop F6 Button";
      #   key = "Meta+Shift+S";
      #   command = "zsh -c ";
      # };
    };
    kscreenlocker.timeout = 15;
    powerdevil = {
      batteryLevels = {
        lowLevel = 30;
        criticalLevel = 5;
      };
      AC.autoSuspend.action = "nothing";
      AC.displayBrightness = 100;
      # battery.whenLaptopLidClosed = "hibernate"; # TODO
      # lowBattery.whenLaptopLidClosed = "hibernate"; #?
      lowBattery.powerProfile = "powerSaving";
    };
    #! broken logout session.sessionRestore.restoreOpenApplicationsOnLogin = "whenSessionWasManuallySaved";
    session.sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";

    workspace = {
      # clickItemTo = "open"; #? breaks type to search func in dolphin
      #? sets only if plasma launches
      #? stylix sets it
      # theme = "breeze-dark";
      # colorScheme = "BreezeDark";
      # cursor.theme = "Breeze_Dark";
      # cursor.size = 24;
      # lookAndFeel =
      #   if (config.stylix.targets.kde.enable) then
      #     "stylix"
      #   else if (config.stylix.polarity == "light") then
      #     "org.kde.breeze.desktop"
      #   else
      #     "org.kde.breezedark.desktop";
      tooltipDelay = 500;
    };

    #? stylix sets it: https://github.com/nix-community/stylix/blob/551df12ee3ebac52c5712058bd97fd9faa4c3430/modules/kde/hm.nix#L258
    # fonts = {};

    # add keepAbove(F) to the left
    kwin.titlebarButtons.left = [
      # MSF
      "more-window-actions"
      #? M(N)SF "application-menu"
      "on-all-desktops"
      "keep-above-windows"
    ];

    window-rules = [
      #? https://nix-community.github.io/plasma-manager/options.xhtml#opt-programs.plasma.window-rules
      #? https://github.com/nix-community/plasma-manager/blob/trunk/modules/window-rules.nix
      #? exact(1),initially(3) are defaults

      {
        apply.Enabled = false;
        description = "restore telegram-desktop position";
        match.window-class = "AyuGram com.ayugram.desktop";
        match.window-types = [ "normal" ];
        apply.position = "1920,756";
        apply.positionrule = 5; # ? now
        apply.size = "1053,640";
        apply.sizerule = 5; # ? now
      }
      {
        apply.Enabled = false;
        description = "restore firefox position";
        match.window-class = "firefox firefox";
        match.window-types = [ "normal" ];
        apply.position = "1920,0";
        apply.positionrule = 5; # ? now
        apply.size = "1396,941";
        apply.sizerule = 5; # ? now
      }

      {
        #! https://github.com/NixOS/nixpkgs/issues/344035#issuecomment-2453113223
        #! https://github.com/VSCodium/vscodium/issues/1414
        description = "code-url-handler fix";
        match.window-class = "code code";
        apply.desktopfile = "${pkgs.vscode}/share/applications/code.desktop";
      }
      {
        description = "daninci-resolve titlebar fix";
        match.window-class = "resolve resolve";
        apply.noborder = false;
      }
      {
        description = "syncthingtray placement fix";
        match.window-class.value = "syncthingtray";
        match.window-class.match-whole = false;
        match.window-types = [ "normal" ];
        match.title = "Syncthing Tray";
        apply.position = "3868,892";
      }
      {
        description = "copyq wayland fix";
        match.window-class.value = "copyq";
        match.window-class.match-whole = false;
        match.window-types = [ "normal" ];
        apply.placement = 7;
        apply.ignoregeometry = true;
        apply.above = true;
        apply.noborder = true;
        apply.fsplevel = 0;
      }
    ]
    ++ (map
      (app: {
        description = "${app.name} PiP above others";
        match = {
          window-class = {
            value = app.class;
            type = "exact";
            match-whole = true;
          };
          title = {
            value = app.title;
            type = "exact";
          };
          window-types = [ "normal" ];
        };
        apply.above = true;
      })
      [
        {
          name = "Telegram";
          class = "AyuGram com.ayugram.desktop";
          title = "AyuGramDesktop";
        }
        {
          name = "Edge";
          class = "msedge msedge";
          title = "Picture in picture";
        }
        {
          name = "Firefox";
          class = "firefox firefox";
          title = "Picture-in-Picture";
        }
      ]
    );

    panels = [
      # Windows-like panel at the bottom
      {
        location = "bottom";
        floating = true;
        height = 44;
        # screen = 0;
        screen = "all";
        widgets = [
          {
            kickoff.icon = "nix-snowflake";
          }
          {
            pager.general.showApplicationIconsOnWindowOutlines = true;
          }
          {
            iconTasks = {
              launchers = map (dockApp: "applications:${dockApp}.desktop") meta.dock;
              behavior.grouping.clickAction = "showTooltips";
            };
          }
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
              title = "RAM Usage";
              displayStyle = "org.kde.ksysguard.linechart";
              sensors = [
                {
                  name = "memory/physical/usedPercent";
                  color = "0,255,0";
                  label = "RAM %";
                }
                {
                  name = "cpu/all/usage";
                  color = "255,0,0";
                  label = "CPU %";
                }
              ];
              totalSensors = [
                "memory/physical/used"
                "memory/physical/usedPercent"
              ];
              textOnlySensors = [
                "memory/physical/used"
                "memory/physical/total"
                "cpu/all/coreCount"
              ];
            };
          }
          {
            systemTray = {
              icons.spacing = "small";
              items = {
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
    # TODO: isAsus
    input.touchpads = [
      {
        vendorId = "04F3";
        productId = "3098";
        name = "ELAN1201:00 04F3:3098 Touchpad";
        naturalScroll = true;
        scrollSpeed = 0.3;
      }
    ];

    shortcuts = {
      "KDE Keyboard Layout Switcher" = {
        "Switch to Next Keyboard Layout" = "Meta+Space";
      };
      "services/systemsettings.desktop" = {
        "_launch" = "Meta+I";
      };
      "kwin" = {
        # "Edit Tiles" = "none";
        "Overview" = "Meta+Tab";
        "Window Above Other Windows" = "Meta+Ctrl+T";
        "Window Fullscreen" = "F11";
        "Peek at Desktop" = "Launch (7)";
        "Switch One Desktop to the Left" = "Launch (6)";
        "Switch One Desktop to the Right" = "Launch (9)";
      };

      # [plasmashell]
      # show-on-mouse-pos=none,Meta+V,Show Clipboard Items at Mouse Position
      # "plasmashell" = {
      #   "show-on-mouse-pos" = "";
      # };
      # "services/com.github.hluk.copyq.desktop" = {
      #   "_launch" = "Meta+V";
      # };

      "services/org.kde.konsole.desktop" = {
        "_launch" = "none";
      };
      "services/org.kde.spectacle.desktop" = {
        "_launch" = "Print";
      };
      "services/org.kde.plasma-systemmonitor.desktop" = {
        "_launch" = [
          "Meta+Esc"
          "Ctrl+Shift+Esc"
        ];
      };

      "services/org.wezfurlong.wezterm.desktop" = {
        "_launch" = [
          "Meta+T"
          "Ctrl+Alt+T"
          "Meta+`"
        ];
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
      #? didn't need with stylix
      # "kdeglobals"."KDE"."AutomaticLookAndFeel" = true;
      # "kdeglobals"."KDE"."DefaultLightLookAndFeel" = "org.kde.breezetwilight.desktop";
      # "kdeglobals"."KDE"."DefaultDarkLookAndFeel" = "stylix";
      #? setted by stylix
      # "kdeglobals"."KDE"."LookAndFeelPackage" = "stylix";

      #! workspace.enableMiddleClickPaste = false; don't work
      "kwinrc"."Wayland"."EnablePrimarySelection" = false;
      #? higher is stronger prevention (0-4, 1 is default) ((4 removes focus stealing from win menu and screenshot))
      #? ((2+ https://github.com/bugaevc/wl-clipboard/issues/268))
      # "kwinrc"."Windows"."FocusStealingPreventionLevel" = 3;
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

      #? https://github.com/nix-community/stylix/issues/267#issuecomment-2314636091
      "kded5rc"."Module-gtkconfig"."autoload" = false;

      "bluedevilglobalrc"."General"."launchState" = "enable";
    };
  };
  #? NIXOS_OZONE_WL=1 fixes that
  # dconf.settings."org/gnome/desktop/interface" = {
  #   gtk-enable-primary-paste = false;
  # };

  # TODO: mkIf browser enabled
  # TODO: other kwin scripts like https://store.kde.org/p/2138867 https://github.com/micha4w/kde-alt-f4-desktop
  #? https://store.kde.org/p/2313455
  # 0.0.3
  xdg.dataFile."kwin/scripts/auto-active".source = fetchTarball {
    url = "https://github.com/ruanimal/auto-active/archive/f5e550f659017d79825a698acfc6a6eb3ded8ec5.tar.gz";
    sha256 = "sha256-9dVf9m47m916cz6oPVZenCCAlucVQbyb1ZjZhvWw0HI=";
  };
  programs.plasma.configFile."kwinrc".Plugins = {
    "auto-activeEnabled" = true;
    # Add config, e.g., Whitelist = "sublime_text,org.kde.dolphin";
  };
}
