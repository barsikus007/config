{
  lib,
  pkgs,
  config,
  custom,
  ...
}:
{
  #! imports = [ inputs.plasma-manager.homeModules.plasma-manager ];
  home.packages =
    with pkgs;
    (if custom.isAsus then [ supergfxctl-plasmoid ] else [ ])
    ++ [
      (pkgs.writeShellScriptBin "inspect-window" ''
        WINDOW_ID=$(${kdotool}/bin/kdotool getactivewindow)
        if [ -z "$WINDOW_ID" ]; then
          ${lib.getExe libnotify} "Error" "No valid window ID obtained. Did you focus a window?" --urgency=critical
          exit 1
        fi

        PID=$(${kdotool}/bin/kdotool getwindowpid "$WINDOW_ID")
        if [ -z "$PID" ]; then
            ${lib.getExe libnotify} "Error" "No valid PID obtained for window ID $WINDOW_ID." --urgency=critical
            exit 1
        fi

        ${lib.getExe wezterm} start --always-new-process -- ${lib.getExe btop} --filter "$PID"
      '')
    ];

  programs.zsh.initContent = ''explorer.exe() {dolphin --new-window "$@" 1>/dev/null 2>/dev/null & disown}'';
  #? have issues with focus, it should focus to explorer every time
  # programs.zsh.initContent = "alias explorer.exe='kioclient exec'";

  #region gtk
  #! JUST FUCK THIS SHIT: nix shell nixpkgs#kdePackages.qttools --command qdbus org.kde.kded6 /kded org.kde.kded6.loadModule gtkconfig
  home.sessionVariables.GTK2_RC_FILES = config.gtk.gtk2.configLocation;
  gtk = {
    gtk2 = {
      configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      iconTheme.package = pkgs.gnome-icon-theme;
      iconTheme.name = "gnome";
    };
    iconTheme.package = pkgs.kdePackages.breeze-icons;
    iconTheme.name = lib.mkForce (
      if (config.stylix.polarity == "light") then "breeze" else "breeze-dark"
    );
    theme.package = lib.mkForce pkgs.kdePackages.breeze-gtk;
    theme.name = lib.mkForce (if (config.stylix.polarity == "light") then "Breeze" else "Breeze-Dark");
    #? https://nix-community.github.io/home-manager/release-notes.xhtml#sec-release-26.05-state-version-changes
  };
  #endregion gtk

  #? https://github.com/nix-community/plasma-manager
  #? https://nix-community.github.io/plasma-manager/options.xhtml
  programs.plasma = {
    enable = true;
    overrideConfig = true;

    hotkeys.commands =
      if custom.isAsus then
        {
          "laptop-button-rog" = {
            name = "Laptop ROG Button";
            key = "Launch (1)";
            command = "zsh -c asus_demotoggle";
          };
          # "laptop-button-f5" = {
          #   name = "Laptop F5 Button";
          #   key = "Launch (4)";
          #   command = "zsh -c asus_fan";
          # };
          "laptop-button-f6" = {
            name = "Laptop F6 Button";
            key = "Meta+Shift+S";
            command = "zsh -c \"asus_noanime && asus_anime\"";
          };
          "inspect-window" = {
            name = "Open Current Window in btop";
            key = "Meta+Ctrl+`";
            command = "inspect-window";
          };
        }
      else
        { };
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
      #? stylix sets it
      # theme = "breeze-dark";
      # colorScheme = "BreezeDark";
      # cursor.theme = "Breeze_Dark";
      # cursor.size = 24;
      # lookAndFeel =
      #   if (config.stylix.targets.kde.enable) then
      #     "stylix"
      #   else
      #   if (config.stylix.polarity == "light") then
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
              launchers = [
                "applications:org.kde.dolphin.desktop"
                "applications:org.wezfurlong.wezterm.desktop"
                "applications:firefox.desktop"
                # "applications:microsoft-edge.desktop"
                "applications:code.desktop"
                "applications:com.ayugram.desktop.desktop"
                # "applications:discord.desktop"
                "applications:vesktop.desktop"
                # "applications:dorion.desktop"
                "applications:obsidian.desktop"
                "applications:bcompare.desktop"
                "applications:thunderbird.desktop"
              ];
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
    # TODO: isAsus
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
      "kdeglobals"."General"."TerminalApplication" = "wezterm";
      "kdeglobals"."General"."TerminalService" = "org.wezfurlong.wezterm.desktop";
      "kdeglobals"."Shortcuts"."Redo" = "Ctrl+Y";
      # "kdeglobals"."PreviewSettings"."EnableRemoteFolderThumbnail" = true;
      "kdeglobals"."PreviewSettings"."MaximumRemoteSize" = 1073741824; # 1 GiB
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

      "dolphinrc"."General"."ShowFullPath" = true;
      "dolphinrc"."General"."BrowseThroughArchives" = true;
      "dolphinrc"."UiSettings"."ColorScheme" = "";
      # "dolphinrc"."DetailsMode"."PreviewSize" = 16;
      # "dolphinrc"."KFileDialog Settings"."Places Icons Auto-resize" = false;
      # "dolphinrc"."KFileDialog Settings"."Places Icons Static Size" = 22;

      #? https://github.com/nix-community/stylix/issues/267#issuecomment-2314636091
      "kded5rc"."Module-gtkconfig"."autoload" = false;

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

      "bluedevilglobalrc"."General"."launchState" = "enable";
    };
    dataFile = {
      # "dolphin/view_properties/global/.directory"."Dolphin"."ViewMode" = 1;
      # "dolphin/view_properties/global/.directory"."Settings"."HiddenFilesShown" = true;
    };

  };
  home.file.".face.icon".source = builtins.fetchurl {
    url = "https://github.com/barsikus007.png";
    sha256 = "sha256-ifkRxN8PTXOp7zkM8NcEWptT7scvMVkGZlcUs6B+0Dk=";
  };
  # NIXOS_OZONE_WL=1 fixes that
  # dconf.settings."org/gnome/desktop/interface" = {
  #   gtk-enable-primary-paste = false;
  # };
}
