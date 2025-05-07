{ pkgs, inputs, ... }:
{
  imports = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];
  # TODO: if asus
  home.packages = with pkgs; [ supergfxctl-plasmoid ];

  programs.zsh.initExtra = ''explorer.exe() {dolphin --new-window "$@" 1>/dev/null 2>/dev/null & disown}'';

  # https://github.com/nix-community/plasma-manager
  # https://nix-community.github.io/plasma-manager/options.xhtml
  programs.plasma = {
    enable = true;
    overrideConfig = true;

    # TODO: if asus
    hotkeys.commands."laptop-button-rog" = {
      name = "Laptop ROG Button";
      key = "Launch (1)";
      command = "zsh -c demotoggle";
    };
    # hotkeys.commands."laptop-button-f5" = {
    #   name = "Laptop F5 Button";
    #   key = "Launch (4)";
    #   command = "zsh -c fan";
    # };
    hotkeys.commands."laptop-button-f6" = {
      name = "Laptop F6 Button";
      key = "Meta+Shift+S";
      command = "zsh -c \"noanime && anime\"";
    };
    kscreenlocker.timeout = 10;
    powerdevil = {
      batteryLevels = {
        lowLevel = 30;
        criticalLevel = 5;
      };
      AC.autoSuspend.action = "nothing";
      AC.displayBrightness = 100; # TODO: will it fix low brightness after sleep or idk when?
      # battery.whenLaptopLidClosed = "hibernate";
      # lowBattery.whenLaptopLidClosed = "hibernate"; #?
      lowBattery.powerProfile = "powerSaving";
    };
    session.sessionRestore.restoreOpenApplicationsOnLogin = "whenSessionWasManuallySaved";

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

    # add appMenu(N) and keepAbove(F) to the left
    kwin.titlebarButtons.left = [
      # MNSF
      "more-window-actions"
      "application-menu"
      "on-all-desktops"
      "keep-above-windows"
    ];

    window-rules = [
      {
        description = "Telegram PiP above others";
        match = {
          window-class = {
            value = "ayugram-desktop com.ayugram.desktop";
            type = "exact";
            match-whole = true;
          };
          title = {
            value = "AyuGramDesktop";
            type = "exact";
          };
          window-types = [ "normal" ];
        };
        apply = {
          above = {
            value = true;
            apply = "force";
          };
        };
      }
      {
        description = "Edge PiP above others";
        match = {
          window-class = {
            value = "msedge msedge";
            type = "exact";
            match-whole = true;
          };
          title = {
            value = "Picture in picture";
            type = "exact";
          };
          window-types = [ "normal" ];
        };
        apply = {
          above = {
            value = true;
            apply = "force";
          };
        };
      }
    ];

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
              launchers = [
                # TODO not linked to anything
                "applications:org.kde.dolphin.desktop"
                "applications:org.wezfurlong.wezterm.desktop"
                "applications:microsoft-edge.desktop"
                # TODO WHYYYY https://github.com/VSCodium/vscodium/issues/1414
                "applications:code.desktop"
                "applications:code-url-handler.desktop"
                "applications:com.ayugram.desktop.desktop"
                "applications:vesktop.desktop"
                "applications:obsidian.desktop"
                # autolaunched
                # "applications:nekoray.desktop"
              ];
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
                  "dev.jhyub.supergfxctl"
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
    input.touchpads = [
      {
        vendorId = "04F3";
        productId = "3098";
        name = "ELAN1201:00 04F3:3098 Touchpad";
        naturalScroll = true;
        # scrollSpeed = 0.5;
        scrollSpeed = 0.3;
        # scrollSpeed = 0.1;
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
        "Window Above Other Windows" = "Meta+Ctrl+T";
        "Window Fullscreen" = "F11";
      };
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
      "kdeglobals"."General"."TerminalApplication" = "wezterm";
      "kdeglobals"."General"."TerminalService" = "org.wezfurlong.wezterm.desktop";
      "kdeglobals"."Shortcuts"."Redo" = "Ctrl+Y";

      #! workspace.enableMiddleClickPaste = false; don't work
      "kwinrc"."Wayland"."EnablePrimarySelection" = false;
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

      "dolphinrc"."General"."ShowFullPath" = true;
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

      # "bluedevilglobalrc"."General"."launchState" = "enable";
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
  # NIXOS_OZONE_WL=1 fixes that
  # dconf.settings."org/gnome/desktop/interface" = {
  #   gtk-enable-primary-paste = false;
  # };
}
