{
  lib,
  pkgs,
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
    # TODO: noctalia v5: shitty shit, it doesn't handle loginctl lock-session
    switch-events.lid-close.action.spawn = [
      "sh"
      "-c"
      "[ $(niri msg --json outputs | ${lib.getExe pkgs.jq} 'keys | length') == '1' ] && noctalia-shell ipc call lockScreen lock"
    ];
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
    #! vibecoded shitfix for clipboard
    #! autoPaste делает `wl-copy && wtype` без паузы -> Ctrl+Shift+V прилетает раньше возврата фокуса в niri
    #? добавляем задержку перед wtype, чтобы синтетическая вставка попадала в целевое окно
    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + /* shell */ ''
        substituteInPlace Services/Keyboard/ClipboardService.qml \
          --replace-fail 'wtype -M ctrl -k v' 'sleep 0.12; wtype -M ctrl -k v' \
          --replace-fail 'wtype -M ctrl -M shift v' 'sleep 0.12; wtype -M ctrl -M shift v'
      '';
    });
    settings = {
      #? https://docs.noctalia.dev/getting-started/nixos/#config-ref
      appLauncher = {
        overviewLayer = true;
        enableClipboardHistory = true;
        autoPasteClipboard = true;
        #? already handled by services.cliphist
        clipboardWatchTextCommand = "";
        clipboardWatchImageCommand = "";
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
        allowPasswordWithFprintd = true;
      };
      #! vibecoded shitfix for fprint pam
      hooks = {
        enabled = true;
        #? allowPasswordWithFprintd's occupy-verify leaves the goodix driver with a phantom sensor claim; killing that process doesn't release it, only tearing down fprintd does
        #! SIGKILL instead of `restart`: fprintd's graceful stop hangs on the wedged verify until its 20s TimeoutStopSec, and it is dbus-activated so the next sudo/noctalia spawns a fresh one in ~1s
        #? passwordless kill is granted by a polkit rule in modules/desktop/manager/niri-de.nix
        screenUnlock = "${lib.getExe' pkgs.systemd "systemctl"} kill --signal=KILL fprintd.service";
      };
      location = {
        #? to make this work, add `api.noctalia.dev` to PBR
        autoLocate = true;
        firstDayOfWeek = 1;
        monthBeforeDay = false;
        use12hourFormat = false;
      };
      notifications.sounds = {
        enabled = true;
        respectExpireTimeout = true;
        separateSounds = true;
        criticalSoundFile = pkgs.fetchurl {
          url = "https://deltarune.wiki/images/Snd_ominous_music.wav";
          hash = "sha256-Dv1sO1/Se90U8S7sIuRxMihKgctm/j/q/ccvxATYSOM=";
        };
      };
      plugins.autoUpdate = true;
      idle =
        let
          # noctalia_ipc_call = "${lib.getExe config.programs.noctalia-shell.package} ipc call";
          is_locked =
            builtins.replaceStrings [ ''"'' ] [ ''\"'' ]
              ''[ $(loginctl show-session $XDG_SESSION_ID -p LockedHint --value) == "yes" ]'';
          power_off_monitors_cmd = "${lib.getExe config.programs.niri.package} msg action power-off-monitors";

          lockscreen_command = ''{"name":"Lockscreen turn off displays","timeout":30,"command":"${is_locked} && ${power_off_monitors_cmd}"}'';
          # dim_command = ''{"name":"Dim monitors","timeout":300,"command":"${noctalia_ipc_call} brightness set 0","resumeCommand":"${noctalia_ipc_call} brightness set 100"}'';

          #! vibecoded shitfix for https://bugzilla.mozilla.org/show_bug.cgi?id=2033358
          #? firefox wayland popups break after monitors power-cycle (screenOff/lock) and lose gtk workarea
          #? only a logical-geometry change makes firefox recompute; nudge eDP-1 position 1px and back on resume
          #? position is read live so it stays correct across output profiles; runs after monitors are back on
          ff_popup_recover = pkgs.writeShellScript "ff-popup-recover" /* shell */ ''
            niri=${lib.getExe config.programs.niri.package}
            jq=${lib.getExe pkgs.jq}
            #? resume is racy: monitors/firefox may still be waking, so a single early nudge gets missed
            #? settle first, then nudge a few times spaced out so at least one lands after everything is back
            sleep 2
            for _ in 1 2 3; do
              out=$("$niri" msg --json outputs)
              x=$(printf '%s' "$out" | "$jq" -r '."eDP-1".logical.x')
              y=$(printf '%s' "$out" | "$jq" -r '."eDP-1".logical.y')
              "$niri" msg output eDP-1 position set "$x" "$((y + 1))"
              sleep 0.5
              "$niri" msg output eDP-1 position set "$x" "$y"
              sleep 1
            done
          '';
          #? timeout below screenOffTimeout so this timer is armed before monitors power off,
          #? guaranteeing its resumeCommand fires when they come back
          ff_recover_command = ''{"name":"Firefox popup recovery","timeout":590,"command":":","resumeCommand":"${ff_popup_recover}"}'';
        in
        {
          enabled = true;
          screenOffTimeout = 600;
          lockTimeout = 900;
          suspendTimeout = 0;
          customCommands = "[${
            lib.strings.concatStringsSep "," [
              lockscreen_command
              ff_recover_command
              # dim_command
            ]
          }]";
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
        # kde-connect = {
        #   enabled = true;
        #   sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        # };
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
