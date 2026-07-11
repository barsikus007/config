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

  nixos_logo = "${config.programs.noctalia.package}/share/noctalia/assets/images/distros/nixos.svg";

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
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.niri.settings = {
    switch-events.lid-close.action.spawn = [
      "sh"
      "-c"
      "[ $(niri msg --json outputs | ${lib.getExe pkgs.jq} 'keys | length') == '1' ] && loginctl lock-session"
    ];
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
          action = noctalia-ipc "brightness-up";
        };
        "XF86MonBrightnessDown" = {
          allow-when-locked = true;
          action = noctalia-ipc "brightness-down";
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
            "temp"
            "noctalia/screen_recorder:recorder"
            "active_window"
          ];
          center = [ "workspaces" ];
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
      # TODO: desktop_widgets = { };
      dock = {
        enabled = true;
        auto_hide = true;
        launcher_custom_image = nixos_logo;
        launcher_position = "start";
        pinned = meta.dock;
        reserve_space = false;
        show_dots = true;
      };
      hooks = {
        #! noctalia password unlock locks frintd (polkit-rule needed)
        session_unlocked = "${lib.getExe' pkgs.systemd "systemctl"} kill --signal=KILL fprintd.service";
      };
      idle = {
        pre_action_fade_seconds = 5;
        behavior_order = [
          "lock"
          "screen-off"
          "ff-recover"
        ];
        behavior = {
          lock = {
            enabled = true;
            action = "lock";
            timeout = 900.0;
          };
          "screen-off" = {
            enabled = true;
            action = "screen_off";
            timeout = 600.0;
          };
          "ff-recover" = {
            enabled = true;
            action = "command";
            timeout = 590.0;
            command = ":";
            resume_command = "${ff_popup_recover}";
          };
        };
      };
      #? to make this work, add `api.noctalia.dev` to PBR
      location.auto_locate = true;
      lockscreen.blurred_desktop = true;
      # TODO: lockscreen_widgets = { };
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
        ];
        source = [
          {
            name = "official";
            kind = "git";
            location = "https://github.com/noctalia-dev/official-plugins";
            auto_update = true;
            enabled = true;
          }
        ];
        # TODO: noctalia-v5: keybind-cheatsheet, currency-exchange, kde-connect, pomodoro
      };
      shell = {
        clipboard_auto_paste = "ctrl_v";
        clipboard_image_action_command = "satty -f -";
        clipboard_history_max_entries = 500;
        launch_apps_as_systemd_services = true;
        mpris.blacklist = [ "firefox.instance" ];
        niri_overview_type_to_launch_enabled = true;
        panel = {
          open_near_click_control_center = true;
          transparency_mode = "glass";
        };
        password_style = "random";
        polkit_agent = true;
        screen_corners.enabled = true;
        screen_time_enabled = true;
      };
      widget = {
        battery = {
          type = "battery";
          display_mode = "graphic";
        };
        clock = {
          type = "clock";
          format = "{:%Y-%m-%d %H:%M:%S}";
        }
        // lib.attrsets.optionalAttrs (options ? stylix) {
          font_family = config.stylix.fonts.monospace.name;
        };
        control-center.custom_image = nixos_logo;
        keyboard_layout = {
          type = "keyboard_layout";
          show_icon = false;
          custom_labels = {
            "English (US)" = "🇺🇸";
            Russian = "🇷🇺";
          };
        };
        music_button = {
          type = "custom_button";
          glyph = "music-pin";
          command = "dbus-send --type=method_call --dest=org.kde.plasma.browser_integration /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Raise";
        };
        privacy.hide_inactive = true;
        tray.drawer = true;
      };
    };
  };
  #? noctalia have own polkit now
  services.polkit-gnome.enable = false;
  #? screenshot annotation for clipboard history (shell.clipboard_image_action_command)
  programs.satty.enable = true;
}
