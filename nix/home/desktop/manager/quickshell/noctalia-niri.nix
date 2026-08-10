{
  lib,
  pkgs,
  config,
  inputs,
  options,
  ...
}:
#? https://github.com/noctalia-dev/noctalia
let
  meta = import ../../meta.nix;

  nixos_logo = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];
  custom.persist.home.directories = [ ".cache/noctalia" ]; # ? to disable prompt on startup

  programs.niri.settings = {
    binds =
      with config.lib.niri.actions;
      let
        noctalia-ipc = spawn "noctalia" "msg";
      in
      {
        # TODO: noctalia-v5: plugin: keybind-cheatsheet for Mod+F1
        "Alt+Space" = {
          hotkey-overlay.title = "Toggle Application Launcher";
          action = noctalia-ipc "panel-toggle" "launcher";
        };
        "Mod+Alt+I" = {
          hotkey-overlay.title = "Toggle Settings";
          action = noctalia-ipc "settings-toggle";
        };
        "Ctrl+Alt+Delete" = {
          hotkey-overlay.title = "Toggle Power Menu";
          action = noctalia-ipc "panel-toggle" "session";
          allow-when-locked = true;
        };

        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action = noctalia-ipc "volume-up";
        };
        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action = noctalia-ipc "volume-down";
        };
        "XF86AudioMute" = {
          allow-when-locked = true;
          action = noctalia-ipc "volume-mute";
        };
        "XF86AudioMicMute" = {
          allow-when-locked = true;
          action = noctalia-ipc "mic-mute";
        };
        "Alt+XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action = noctalia-ipc "mic-volume-up";
        };
        "Alt+XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action = noctalia-ipc "mic-volume-down";
        };
        "XF86MonBrightnessUp" = {
          allow-when-locked = true;
          action = noctalia-ipc "brightness-up" "*";
        };
        "XF86MonBrightnessDown" = {
          allow-when-locked = true;
          action = noctalia-ipc "brightness-down" "*";
        };

        "Mod+V" = {
          hotkey-overlay.title = "Toggle Clipboard Manager";
          action = noctalia-ipc "panel-toggle" "clipboard";
        };
        #? "Mod+Period"
        "Mod+Semicolon" = {
          hotkey-overlay.title = "Toggle Emoji Picker 🤓";
          action = noctalia-ipc "panel-toggle" "launcher" "/emo";
        };
      }
      // lib.attrsets.optionalAttrs config.custom.isAsus {
        "XF86Launch4" = {
          hotkey-overlay.title = "Asus: Cycle Power Profiles";
          action = noctalia-ipc "power-cycle";
        };
        "Mod+Shift+S" = {
          hotkey-overlay.title = "Quick ScreenCapture";
          action = noctalia-ipc "plugin" "noctalia/screen_recorder:service" "all" "toggle";
        };
      };
  };
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings = {
      #? https://github.com/noctalia-dev/noctalia/blob/main/example.toml
      #? code --reuse-window ~/.local/state/noctalia/settings.toml
      audio = {
        enable_sounds = true;
        enable_overdrive = true;
        # TODO: noctalia-v5: this is critical notification sound
        notification_sound = pkgs.fetchurl {
          url = "https://deltarune.wiki/images/Snd_ominous_music.wav";
          hash = "sha256-Dv1sO1/Se90U8S7sIuRxMihKgctm/j/q/ccvxATYSOM=";
        };
        sound_volume = 1.0;
      };
      bar = {
        order = [ "main" ];
        main = {
          capsule = true;
          margin_ends = 0;
          padding = 4;
          start = [
            "control-center"
            "cpu"
            "ram"
            "noctalia/screen_recorder:recorder"
            "thepunkoff/pomodoro:widget"
            "active_window"
          ];
          center = [ "taskbar" ];
          end = [
            "music_button"
            "media"
            "tray"
            "privacy"
            "notifications"
            "network"
            "brightness"
            "volume"
            "battery"
            "keyboard_layout"
            "clock"
          ];
        };
      };
      battery.warning_threshold = 30;
      brightness.enable_ddcutil = true;
      control_center.sidebar = "full";
      dock = {
        enabled = true;
        launcher_custom_image = nixos_logo;
        launcher_position = "start";
        pinned = meta.dock;
        reserve_space = false;
        show_dots = true;
        smart_auto_hide = true;
      };
      hooks = {
        #! noctalia password unlock locks frintd (polkit-rule needed)
        session_unlocked = "${lib.getExe' pkgs.systemd "systemctl"} kill --signal=KILL fprintd.service";
      };
      idle = {
        pre_action_fade_seconds = 5;
        behavior_order = [
          "lock"
          "lock-screen-off"
          "screen-off"
        ];
        behavior = {
          "lock" = {
            enabled = true;
            action = "lock";
            timeout = 900.0;
          };
          #? power off monitors 60s into idle, but only when session is already locked
          "lock-screen-off" = {
            enabled = true;
            action = "command";
            timeout = 60.0;
            command = ''[ "$(loginctl show-session $XDG_SESSION_ID -p LockedHint --value)" = "yes" ] && ${lib.getExe config.programs.niri.package} msg action power-off-monitors'';
          };
          "screen-off" = {
            enabled = true;
            action = "screen_off";
            timeout = 600.0;
          };
        };
      };
      #? to make this work, add `api.noctalia.dev` to PBR
      location.auto_locate = true;
      lockscreen.blurred_desktop = true;
      #? login_box'es sets automatically
      lockscreen_widgets =
        let
          monitors = {
            "eDP-1" = {
              width = 1920;
              height = 1080;
            };
            "HDMI-A-1" = {
              width = 2560;
              height = 1440;
            };
          };
          mkWidgets =
            output:
            { width, height }:
            {
              "clock@${output}" = {
                type = "clock";
                inherit output;
                cx = width / 2.0;
                cy = height / 6.0;
                settings = {
                  center_text = true;
                  format = "{:%d %b %Y\\n%H:%M:%S}";
                };
              };
              "visualizer@${output}" = {
                type = "fancy_audio_visualizer";
                inherit output;
                cx = width / 2.0;
                cy = height / 2.0;
                settings.visualization_mode = "all";
              };
            };
        in
        {
          enabled = true;
          widget = lib.foldl' (acc: w: acc // w) { } (lib.mapAttrsToList mkWidgets monitors);
        };
      osd = {
        position = "top_right";
        kinds = {
          lock_keys = false;
          media = false;
        };
      };
      plugin_settings."noctalia/screen_recorder" = {
        copy_to_clipboard = true;
        frame_rate = 144;
        video_codec = "hevc";
        audio_source = "both";
      };
      plugins = {
        enabled = [
          "noctalia/screen_recorder"
          "noctalia/kaomoji"
          "noctalia/timer"

          "whyoolw/sharednd"
          "thepunkoff/pomodoro"
        ];
        source = [
          {
            name = "official";
            kind = "git";
            location = "https://github.com/noctalia-dev/official-plugins";
            enabled = true;
          }
          {
            name = "community";
            kind = "git";
            location = "https://github.com/noctalia-dev/community-plugins";
            enabled = true;
          }
        ];
        # TODO: noctalia-v5: timer:bar-widget, kde-connect
      };
      shell = {
        clipboard_auto_paste = "ctrl_v";
        clipboard_image_action_command = "satty -f -";
        clipboard_history_max_entries = 500;
        keyboard_layout.custom_labels = {
          "English (US)" = "🇺🇸";
          Russian = "🇷🇺";
        };
        launch_apps_as_systemd_services = true;
        mpris.blacklist = [ "firefox.instance" ];
        niri_overview_type_to_launch_enabled = true;
        panel = {
          list_item_background = true;
          open_near_click_control_center = true;
          transparency_mode = "glass";
        };
        password_style = "random";
        polkit_agent = true;
        screen_corners.enabled = true;
        screen_time_enabled = true;
      };
      widget = {
        control-center.custom_image = nixos_logo;
        cpu.visualization = "graph";
        ram.visualization = "graph";

        taskbar.group_by_workspace = true;

        tray = {
          drawer = true;
          pinned = [ "Syncthing Tray" ];
        };
        music_button = {
          type = "custom_button";
          glyph = "music-pin";
          actions.left = "exec dbus-send --type=method_call --dest=org.kde.plasma.browser_integration /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Raise";
        };
        privacy.hide_inactive = true;
        network.show_label = false;
        battery = {
          type = "battery";
          display_mode = "graphic";
        };
        keyboard_layout = {
          type = "keyboard_layout";
          show_glyph = false;
        };
        clock = {
          type = "clock";
          format = "{:%Y-%m-%d %H:%M:%S}";
        }
        // lib.attrsets.optionalAttrs (options ? stylix) {
          font_family = config.stylix.fonts.monospace.name;
        };
      };
    };
  };
  #? noctalia have own polkit now
  services.polkit-gnome.enable = false;
  #? screenshot annotation for clipboard history (shell.clipboard_image_action_command)
  programs.satty.enable = true;
}
