{
  lib,
  pkgs,
  config,
  ...
}:
let
  gsr-ui = lib.getExe pkgs.gpu-screen-recorder-ui;
  gsr-ui-cli = lib.getExe' pkgs.gpu-screen-recorder-ui "gsr-ui-cli";
  powerprofilesctl = lib.getExe' pkgs.power-profiles-daemon "powerprofilesctl";
  notify-send = lib.getExe pkgs.libnotify;
  niri = lib.getExe pkgs.niri;
  jq = lib.getExe pkgs.jq;
  gnused = lib.getExe pkgs.gnused;
  inherit (pkgs) coreutils gnugrep;
  systemctl = lib.getExe' pkgs.systemd "systemctl";
  flock = lib.getExe' pkgs.util-linux "flock";
  gpu-screen-recorder = lib.getExe pkgs.gpu-screen-recorder;
  slurp = lib.getExe pkgs.slurp;
  wl-copy = lib.getExe' pkgs.wl-clipboard "wl-copy";
  xdg-open = lib.getExe' pkgs.xdg-utils "xdg-open";

  videoCodec = "hevc";
  audioCodec = "opus";

  record.videoFps = 144;
  replay.videoFps = 60;

  #? audio tracks definition shared between gsr-ui ini config and cli invocations
  rawTracks = [
    [
      "name:both"
      "device:default_output"
      "device:default_input"
    ]
    [
      "name:output"
      "device:default_output"
    ]
    [
      "name:input"
      "device:default_input"
    ]
    [
      "name:browser"
      "app:Firefox"
    ]
    [
      "name:discord"
      "app:WEBRTC VoiceEngine"
    ]
  ];

  #? gsr-ui config format: one [add_audio_track] per track, items prefixed with false
  audioTracks = lib.concatMap (
    items: [ "false [add_audio_track]" ] ++ map (i: "false ${i}") items
  ) rawTracks;

  #? cli flags for gpu-screen-recorder
  audioCliFlags = lib.concatMapStringsSep " " (
    items: "-a \"${lib.concatStringsSep "|" items}\""
  ) rawTracks;

  #? his live non-default settings (diffed against Config.hpp defaults): activation drops
  #? these keys from the file and appends them back, every other key survives UI edits
  managedSettings = {
    "main.hotkeys_enable_option" = [ "enable_hotkeys_no_grab" ];
    "main.tint_color" = [ "intel" ];
    "main.show_hide_hotkey" = [ "0 0" ];
    "screenshot.take_screenshot_hotkey" = [ "0 0" ];
    "record.record_options.advanced_view" = [ "true" ];
    "record.record_options.audio_codec" = [ audioCodec ];
    "record.record_options.audio_track_item" = audioTracks;
    "record.record_options.codec" = [ videoCodec ];
    "record.record_options.fps" = [ (toString record.videoFps) ];
    "replay.record_options.advanced_view" = [ "true" ];
    "replay.record_options.audio_codec" = [ audioCodec ];
    "replay.record_options.audio_track_item" = audioTracks;
    "replay.record_options.codec" = [ videoCodec ];
    "replay.record_options.fps" = [ (toString replay.videoFps) ];
    "replay.record_options.video_bitrate" = [ "20000" ];
    "replay.time" = [ "600" ];
    "replay.save_directory" = [ "${config.home.homeDirectory}/Videos/Replays" ];
    "replay.only_start_replay_if_power_supply_connected" = [ "true" ];
  };

  managedBlock = pkgs.writeText "gsr-ui-managed-config" (
    lib.concatStrings (
      lib.mapAttrsToList (
        key: values: lib.concatMapStringsSep "\n" (value: "${key} ${value}") values + "\n"
      ) managedSettings
    )
  );

  keyPattern = "^(${
    lib.concatMapStringsSep "|" (key: lib.escape [ "." ] key) (lib.attrNames managedSettings)
  }) ";

  #? interactive screen recording (portal or slurp region) with multi-track audio, toggle control, and clipboard copy
  record-runner = pkgs.writeShellScript "gpu-screen-recorder-record" ''
    mode="''${1:-portal}"
    uid="$(${coreutils}/bin/id --user)"
    lock_file="''${XDG_RUNTIME_DIR:-/run/user/$uid}/gsr-recording.lock"
    exec 9>"$lock_file"
    ${flock} --timeout 2 9 || exit 0

    pid_file="''${XDG_RUNTIME_DIR:-/run/user/$uid}/gsr-recording.pid"
    info_file="''${XDG_RUNTIME_DIR:-/run/user/$uid}/gsr-recording.info"

    if [ -f "$pid_file" ]; then
      pid="$(${coreutils}/bin/cat "$pid_file" 2>/dev/null || true)"
      if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
        target_file=""
        if [ -f "$info_file" ]; then
          target_file="$(${coreutils}/bin/cat "$info_file" 2>/dev/null || true)"
        fi

        #? finalize recording container
        kill -SIGINT "$pid" 2>/dev/null || true

        for _ in $(seq 1 50); do
          kill -0 "$pid" 2>/dev/null || break
          ${coreutils}/bin/sleep 0.1
        done

        if kill -0 "$pid" 2>/dev/null; then
          kill -9 "$pid" 2>/dev/null || true
        fi

        ${coreutils}/bin/rm --force "$pid_file" "$info_file"
        exec 9>&-

        if [ -n "$target_file" ] && [ -s "$target_file" ]; then
          ${coreutils}/bin/printf 'file://%s\n' "$target_file" | ${wl-copy} --type text/uri-list

          filename="$(${coreutils}/bin/basename "$target_file")"
          target_dir="$(${coreutils}/bin/dirname "$target_file")"

          action="$(${notify-send} \
            --app-name="GPU Screen Recorder" \
            --icon=video-x-generic \
            --expire-time=5000 \
            --hint=boolean:suppress-sound:true \
            --action=open="Open" \
            --action=folder="Show in folder" \
            "Recording saved" \
            "$filename (copied to clipboard)" 2>/dev/null || true)"

          case "$action" in
            (open)
              ${xdg-open} "$target_file" 9>&- &
              ;;
            (folder)
              ${xdg-open} "$target_dir" 9>&- &
              ;;
          esac
        else
          ${notify-send} \
            --app-name="GPU Screen Recorder" \
            --icon=video-x-generic \
            --expire-time=3000 \
            --hint=boolean:suppress-sound:true \
            "Recording stopped" \
            "No video file was created" 2>/dev/null || true
        fi
        exit 0
      else
        ${coreutils}/bin/rm --force "$pid_file" "$info_file"
      fi
    fi

    if [ "$mode" = "region" ]; then
      region="$(${slurp} -f "%wx%h+%x+%y" 2>/dev/null || true)"
      if [ -z "$region" ]; then
        exec 9>&-
        exit 0
      fi
      target_val="$region"
      start_msg="Region recording started"
    else
      target_val="portal"
      start_msg="Screen recording started"
    fi

    record_dir="${config.home.homeDirectory}/Videos/Recordings"
    ${coreutils}/bin/mkdir --parents "$record_dir"

    timestamp="$(${coreutils}/bin/date +%Y-%m-%d'_'%H_%M_%S)"
    output_file="$record_dir/Recording_$timestamp.mp4"

    #? start gsr in portal/region mode with separated audio tracks; 9>&- prevents child from inheriting the lock fd
    ${gpu-screen-recorder} \
      -w "$target_val" \
      -fm vfr \
      -f ${toString record.videoFps} \
      -k ${videoCodec} \
      -ac ${audioCodec} \
      -bm qp \
      -ffmpeg-video-opts 'qp=25' \
      -cursor yes \
      -cr limited \
      -v no \
      ${audioCliFlags} \
      -o "$output_file" 9>&- &

    gsr_pid=$!
    ${coreutils}/bin/printf '%s' "$gsr_pid" > "$pid_file"
    ${coreutils}/bin/printf '%s' "$output_file" > "$info_file"
    exec 9>&-

    (
      while kill -0 "$gsr_pid" 2>/dev/null; do
        if [ -f "$output_file" ]; then
          ${notify-send} \
            --app-name="GPU Screen Recorder" \
            --icon=video-x-generic \
            --expire-time=2000 \
            --hint=boolean:suppress-sound:true \
            "Recording" \
            "$start_msg" 2>/dev/null || true
          break
        fi
        ${coreutils}/bin/sleep 0.2
      done

      while kill -0 "$gsr_pid" 2>/dev/null; do
        ${coreutils}/bin/sleep 0.5
      done

      if [ -f "$pid_file" ]; then
        recorded_pid="$(${coreutils}/bin/cat "$pid_file" 2>/dev/null || true)"
        if [ "$recorded_pid" = "$gsr_pid" ]; then
          ${coreutils}/bin/rm --force "$pid_file" "$info_file"
          if [ ! -s "$output_file" ]; then
            ${coreutils}/bin/rm --force "$output_file"
          fi
        fi
      fi
    ) 9>&- &
  '';

  record-portal = pkgs.writeShellScriptBin "gpu-screen-recorder-record-portal" ''
    exec ${record-runner} portal "$@"
  '';

  record-region = pkgs.writeShellScriptBin "gpu-screen-recorder-record-region" ''
    exec ${record-runner} region "$@"
  '';
in
{
  home.packages = [
    record-portal
    record-region
  ];
  systemd.user.services.gsr-ui = {
    Unit = {
      Description = "GPU Screen Recorder overlay (instant replay)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      StartLimitIntervalSec = 30;
      StartLimitBurst = 3;
    };
    Service = {
      #? login-time gate only; after that power-profiles.nix actions start/stop on profile changes
      ExecCondition = lib.getExe (
        pkgs.writeShellScriptBin "gsr-ui-profile-check" ''
          [ "$(${powerprofilesctl} get)" != "power-saver" ]
        ''
      );
      #? the wrapper puts /run/wrappers/bin (gsr-kms-server, gsr-global-hotkeys) and
      #? gpu-screen-recorder itself on PATH, so the child gsr needs no Environment here
      #? detect monitors via niri and prompt with notify-send before daemon start;
      #? lets user switch to another screen or cancel, defaulting to Samsung or single screen
      ExecStartPre =
        let
          select-monitor = pkgs.writeShellScript "gsr-ui-select-monitor" ''
            outputs="$(${niri} msg --json outputs 2>/dev/null || true)"
            [ -n "$outputs" ] || exit 0

            config_dir="${config.xdg.configHome}/gpu-screen-recorder"
            config_file="$config_dir/config_ui"

            set_config_key() {
              local key="$1"
              local val="$2"
              ${coreutils}/bin/mkdir --parents "$config_dir"
              ${coreutils}/bin/touch "$config_file"
              if ${gnugrep}/bin/grep --quiet "^$key " "$config_file" 2>/dev/null; then
                ${gnused} --in-place "s|^$key .*|$key $val|" "$config_file"
              else
                printf '%s %s\n' "$key" "$val" >> "$config_file"
              fi
            }

            eval "$(${coreutils}/bin/printf '%s' "$outputs" | ${jq} --raw-output '
              to_entries as $all |
              ($all | map(select(.value.model == "C27JG5x")) | .[0].key) as $samsung |
              (
                "total=" + (($all | length) | tostring),
                "samsung=" + ($samsung // "" | @sh)
              )
            ')"

            actions=()

            if [ -n "$samsung" ]; then
              candidate="$samsung"
              candidate_name="Samsung C27JG5x ($samsung)"
            elif [ "$total" -eq 1 ]; then
              candidate="$(${coreutils}/bin/printf '%s' "$outputs" | ${jq} --raw-output 'keys[0]')"
              candidate_name="$candidate"
            else
              candidate=""
              candidate_name=""
            fi

            if [ -n "$candidate" ]; then
              summary="Replay"
              body="Recording display: $candidate_name"
              actions+=("--action=default=Record $candidate_name")
              while IFS= read -r m; do
                [ -n "$m" ] || continue
                [ "$m" = "$candidate" ] && continue
                actions+=("--action=$m=Switch to $m")
              done < <(${coreutils}/bin/printf '%s' "$outputs" | ${jq} --raw-output 'keys[]')
              actions+=("--action=disable=Do not record")
            else
              summary="Replay"
              body="Main display not connected. Select display to record:"
              while IFS= read -r m; do
                [ -n "$m" ] || continue
                actions+=("--action=$m=Record on $m")
              done < <(${coreutils}/bin/printf '%s' "$outputs" | ${jq} --raw-output 'keys[]')
              actions+=("--action=disable=Do not record")
            fi

            chosen="$(${notify-send} \
              --app-name="GPU Screen Recorder" \
              --icon=video-x-generic \
              --expire-time=5000 \
              --hint=boolean:suppress-sound:true \
              "''${actions[@]}" \
              "$summary" \
              "$body" 2>/dev/null || true)"

            case "$chosen" in
              (default|"")
                target="$candidate"
                ;;
              (disable)
                target=""
                ;;
              (*)
                target="$chosen"
                ;;
            esac

            if [ -n "$target" ]; then
              set_config_key "replay.turn_on_replay_automatically_mode" "turn_on_at_system_startup"
              set_config_key "replay.record_options.record_area_option" "$target"
            else
              set_config_key "replay.turn_on_replay_automatically_mode" "dont_turn_on_automatically"
            fi
          '';
        in
        "${select-monitor}";
      ExecStart = "${gsr-ui} launch-daemon";
      #? prompt before saving replay on service stop (e.g. unplugging power);
      #? discard if timeout expires without user action
      ExecStop =
        let
          save-on-stop = pkgs.writeShellScript "gsr-ui-save-on-stop" ''
            action="$(${notify-send} \
              --app-name="GPU Screen Recorder" \
              --icon=video-x-generic \
              --expire-time=5000 \
              --hint=boolean:suppress-sound:true \
              --action=default="Save replay" \
              --action=save="Save replay" \
              --action=discard="Discard" \
              "Replay" \
              "Save replay before stopping?" 2>/dev/null || true)"

            case "$action" in
              (default|save)
                ${gsr-ui-cli} replay-save || true
                sleep 3
                ;;
            esac
          '';
        in
        "${save-on-stop}";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.gsr-ui-monitor-hotplug = {
    Unit = {
      Description = "Handle monitor hotplug for GPU Screen Recorder";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart =
        let
          hotplug-script = pkgs.writeShellScript "gsr-ui-hotplug" ''
            uid="$(${coreutils}/bin/id --user)"
            lock_file="''${XDG_RUNTIME_DIR:-/run/user/$uid}/gsr-ui-hotplug.lock"
            exec 9>"$lock_file"
            ${flock} --nonblocking 9 || exit 0

            #? only proceed if gsr-ui is currently active
            ${systemctl} --user is-active --quiet gsr-ui.service || exit 0

            #? ignore events while the display is in DPMS standby/sleep
            edp_dpms="$(${coreutils}/bin/cat /sys/class/drm/card*-eDP-*/dpms 2>/dev/null || true)"
            if [ -n "$edp_dpms" ] && [ "$edp_dpms" != "On" ]; then
              exit 0
            fi

            #? allow niri and kanshi time to settle display topology
            ${coreutils}/bin/sleep 1

            outputs="$(${niri} msg --json outputs 2>/dev/null || true)"
            [ -n "$outputs" ] || exit 0

            config_dir="${config.xdg.configHome}/gpu-screen-recorder"
            config_file="$config_dir/config_ui"
            [ -f "$config_file" ] || exit 0

            set_config_key() {
              local key="$1"
              local val="$2"
              ${coreutils}/bin/mkdir --parents "$config_dir"
              ${coreutils}/bin/touch "$config_file"
              if ${gnugrep}/bin/grep --quiet "^$key " "$config_file" 2>/dev/null; then
                ${gnused} --in-place "s|^$key .*|$key $val|" "$config_file"
              else
                printf '%s %s\n' "$key" "$val" >> "$config_file"
              fi
            }

            current_target="$(${gnugrep}/bin/grep '^replay.record_options.record_area_option ' "$config_file" 2>/dev/null | ${gnused} 's|^replay.record_options.record_area_option ||' || true)"

            eval "$(${coreutils}/bin/printf '%s' "$outputs" | ${jq} --raw-output '
              to_entries as $all |
              ($all | map(select(.value.model == "C27JG5x")) | .[0].key) as $samsung |
              (
                "total=" + (($all | length) | tostring),
                "samsung=" + ($samsung // "" | @sh)
              )
            ')"

            #? case 1: was recording Samsung, but Samsung disconnected
            if [ -z "$samsung" ] && [ "$total" -eq 1 ]; then
              edp_name="$(${coreutils}/bin/printf '%s' "$outputs" | ${jq} --raw-output 'keys[0]')"
              if [ "$current_target" != "$edp_name" ]; then
                action="$(${notify-send} \
                  --app-name="GPU Screen Recorder" \
                  --icon=video-x-generic \
                  --expire-time=5000 \
                  --hint=boolean:suppress-sound:true \
                  --action=switch="Switch to $edp_name" \
                  --action=keep="Keep current" \
                  "Replay" \
                  "Samsung C27JG5x disconnected. Switch recording to $edp_name?" 2>/dev/null || true)"

                case "$action" in
                  (switch)
                    set_config_key "replay.record_options.record_area_option" "$edp_name"
                    set_config_key "replay.turn_on_replay_automatically_mode" "turn_on_at_system_startup"
                    ${systemctl} --user restart gsr-ui.service
                    ;;
                esac
              fi
            #? case 2: was recording eDP-1, but Samsung reconnected
            elif [ -n "$samsung" ] && [ "$current_target" != "$samsung" ]; then
              action="$(${notify-send} \
                --app-name="GPU Screen Recorder" \
                --icon=video-x-generic \
                --expire-time=5000 \
                --hint=boolean:suppress-sound:true \
                --action=switch="Switch to Samsung" \
                --action=keep="Keep current" \
                "Replay" \
                "Samsung C27JG5x connected. Switch recording to Samsung ($samsung)?" 2>/dev/null || true)"

              case "$action" in
                (switch)
                  set_config_key "replay.record_options.record_area_option" "$samsung"
                  set_config_key "replay.turn_on_replay_automatically_mode" "turn_on_at_system_startup"
                  ${systemctl} --user restart gsr-ui.service
                  ;;
              esac
            fi
          '';
        in
        "${hotplug-script}";
    };
  };

  #? gsr-ui rewrites the whole config on any settings save, so a store symlink would
  #? make UI edits unsaveable; merge the managed keys in place instead (without restarting
  #? the unit to preserve the active replay buffer across activations)
  home.activation.gsrUiConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] /* shell */ ''
    config_dir="${config.xdg.configHome}/gpu-screen-recorder"
    config_file="$config_dir/config_ui"
    filtered="$(${pkgs.coreutils}/bin/mktemp)"
    final="$(${pkgs.coreutils}/bin/mktemp)"
    if [ -f "$config_file" ]; then
      ${pkgs.gnugrep}/bin/grep --invert-match --extended-regexp '${keyPattern}' "$config_file" > "$filtered" || true
    fi
    ${pkgs.coreutils}/bin/cat "$filtered" ${managedBlock} > "$final"
    $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir --parents "$config_dir"
    if ! ${pkgs.coreutils}/bin/cmp --silent "$final" "$config_file" 2>/dev/null; then
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/cp "$final" "$config_file"
    fi
    ${pkgs.coreutils}/bin/rm --force "$filtered" "$final"
  '';
}
