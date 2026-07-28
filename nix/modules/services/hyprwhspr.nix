{ pkgs, username, ... }:
#! completely vibecoded hyprwhspr-rs integration
#? native speech-to-text dictation (Rust fork), driven by niri keybind -> `record toggle`
#? https://github.com/better-slop/hyprwhspr-rs
let
  #? knobs
  whisperModel = "large-v3-turbo-q5_0";
  whisperPort = "8765";
  #? stop the resident server after this long without a dictation, to release its ~600M
  whisperIdleSec = 300;

  #? hyprwhspr expands `~` itself, but not $HOME - keep the tilde form for its json config
  modelsDir = "~/.local/share/hyprwhspr-rs/models";
  #? systemd units cannot expand $HOME in ExecStart, they use the %h specifier instead
  modelPath = "%h/.local/share/hyprwhspr-rs/models/ggml-${whisperModel}.bin";
  statusFile = "\${HOME}/.cache/hyprwhspr-rs/status.json";
  activityStamp = "\${XDG_RUNTIME_DIR}/hyprwhspr-last-activity";

  #! prefer the nvidia dGPU when its driver is loaded, else fall back to the Vega iGPU.
  #! measured on a 6s clip (q5_0): RTX 2060 ~0.3s encode, Vega ~3.2s, plain CPU ~25.5s.
  #! the Max-Q ramps P8 -> P0 on its own during the first run, so no warm-up trick is needed.
  #! first run on a cold ~/.cache/nvidia costs ~19s compiling vulkan pipelines (persisted, see
  #! hosts/ROG14/impermanence.nix); mesa/radv recompile fast, so the iGPU shows no such spike
  #? pick by NAME, not by index: vulkan enumeration order changes across dgpu_switch_* (g14.sh),
  #? and __VK_LAYER_NV_optimus=NVIDIA_only no longer reorders anything here
  #? when nvidia is unbound (vfio) it simply is not enumerated, so the grep falls through to AMD
  pickFastestDevice = pkgs.writeShellScript "whisper-pick-device" /* shell */ ''
    devs=$("${pkgs.whisper-cpp-vulkan}/bin/whisper-cli" --help 2>&1)
    idx=$(printf '%s' "$devs" | ${pkgs.gnugrep}/bin/grep -oP 'ggml_vulkan: \K\d+(?= = .*NVIDIA)' | head -1)
    [ -z "''${idx:-}" ] && idx=$(printf '%s' "$devs" | ${pkgs.gnugrep}/bin/grep -oP 'ggml_vulkan: \K\d+(?= = .*(RADV|AMD|Radeon))' | head -1)
    [ -n "''${idx:-}" ] && export GGML_VK_VISIBLE_DEVICES="$idx"
  '';

  whisper-cpp-offload = pkgs.symlinkJoin {
    name = "whisper-cpp-vulkan-offload";
    paths = [ pkgs.whisper-cpp-vulkan ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    #? --run gets `source <script>`: inlining the picker would break on its own quotes
    postBuild = ''
      for b in whisper-cli whisper-server; do
        rm "$out/bin/$b"
        makeWrapper ${pkgs.whisper-cpp-vulkan}/bin/$b "$out/bin/$b" --run 'source ${pickFastestDevice}'
      done
    '';
  };

  #? soft tick, generated (no external asset), looped while transcribing
  processingTick =
    pkgs.runCommand "hyprwhspr-processing-tick" { nativeBuildInputs = [ pkgs.ffmpeg ]; }
      ''
        mkdir -p "$out"
        ffmpeg -f lavfi -i "sine=frequency=520:duration=0.09" \
          -af "afade=t=out:st=0.05:d=0.04,volume=0.22" -ar 48000 "$out/tick.wav"
      '';

  #! -rs writes {class: inactive|active|processing|error} to status.json (atomic, for inotify).
  #! watch it to (a) tick while transcribing - upstream only has start/stop pings, no processing
  #! sound - and (b) spin the resident server up as soon as recording starts, so the model is
  #! already loading while you speak
  statusWatch = pkgs.writeShellScript "hyprwhspr-status-watch" /* shell */ ''
    set -u
    status="${statusFile}"
    stamp="${activityStamp}"
    loop_pid=""
    stop_loop() {
      if [ -n "$loop_pid" ]; then kill "$loop_pid" 2>/dev/null || true; loop_pid=""; fi
    }
    trap stop_loop EXIT
    react() {
      cls=$(${pkgs.jq}/bin/jq -r '.class // empty' "$status" 2>/dev/null || true)
      case "$cls" in
        active)
          touch "$stamp"
          #? --no-block: never stall the watcher on model load
          systemctl --user start --no-block whisper-server.service || true
          #? hush whatever is playing so it does not bleed into the recording
          ${pkgs.playerctl}/bin/playerctl pause 2>/dev/null || true
          stop_loop
          ;;
        processing)
          touch "$stamp"
          if [ -z "$loop_pid" ] || ! kill -0 "$loop_pid" 2>/dev/null; then
            ( while true; do ${pkgs.pipewire}/bin/pw-play "${processingTick}/tick.wav"; sleep 0.4; done ) &
            loop_pid=$!
          fi
          ;;
        *)
          stop_loop
          ;;
      esac
    }
    dir=$(${pkgs.coreutils}/bin/dirname "$status")
    ${pkgs.coreutils}/bin/mkdir -p "$dir"
    react
    #! -rs writes status.json atomically (temp file + rename), so close_write never fires on the
    #! target - watch the directory for moved_to instead, or the watcher just sits there forever
    ${pkgs.inotify-tools}/bin/inotifywait --quiet --monitor --event moved_to,close_write "$dir" \
      | while read -r _ _ file; do
          [ "$file" = "$(${pkgs.coreutils}/bin/basename "$status")" ] && react
        done
  '';

  #! release the model (~600M) after a quiet spell; an explicit stop also defeats Restart=always,
  #! so the server stays down until the next dictation starts it again
  whisperIdleStop = pkgs.writeShellScript "whisper-server-idle-stop" /* shell */ ''
    set -u
    stamp="${activityStamp}"
    last=$(${pkgs.coreutils}/bin/stat -c %Y "$stamp" 2>/dev/null || echo 0)
    now=$(${pkgs.coreutils}/bin/date +%s)
    if [ "$((now - last))" -ge ${toString whisperIdleSec} ]; then
      systemctl --user stop whisper-server.service || true
    fi
  '';

  #? `whspr-status` - which GPU the resident server picked + how long recent dictations took
  whsprStatus = pkgs.writeShellScriptBin "whspr-status" /* shell */ ''
    set -u
    echo "== server =="
    if systemctl --user is-active --quiet whisper-server.service; then
      up=$(systemctl --user show whisper-server.service -p ActiveEnterTimestamp --value)
      echo "  running (since $up), model ${whisperModel}, idle-stop ${toString whisperIdleSec}s"
      #? whisper.cpp lists every vulkan device, then logs `using VulkanN` for the one it picked -
      #! resolve N against the list, or you just print the last device it happened to enumerate
      log=$(journalctl --user -u whisper-server.service -b --no-pager 2>/dev/null)
      n=$(printf '%s' "$log" | ${pkgs.gnugrep}/bin/grep -oP 'using Vulkan\K\d+' | tail -1)
      if [ -n "''${n:-}" ]; then
        printf '%s' "$log" | ${pkgs.gnugrep}/bin/grep -oP "ggml_vulkan: $n = \K[^|]+" | tail -1 \
          | ${pkgs.gnused}/bin/sed "s/^/  device: [Vulkan$n] /"
      else
        echo "  device: unknown (no vulkan backend line in log)"
      fi
    else
      echo "  stopped (starts on next dictation)"
    fi
    if [ -d /proc/driver/nvidia/gpus ]; then
      echo "  nvidia: driver loaded -> dGPU offload active for new starts"
    else
      echo "  nvidia: off/vfio -> falls back to the Vega iGPU"
    fi

    echo "== recent dictations =="
    #? -rs logs one benchmark table per dictation; pair audio length with the wall time
    journalctl --user -u hyprwhspr-rs.service -n 4000 --no-pager 2>/dev/null | ${pkgs.gawk}/bin/awk '
      /Transcribing/     { if (match($0, /Transcribing ([0-9.]+)s/, a)) aud = a[1] }
      #? local backend logs "Transcription: x", the http one "Transcription (whisper-server): x"
      /✅ Transcription/ { if (match($0, /Transcription[^:]*: (.*)$/, t)) txt = t[1] }
      /│ Total/          { if (match($0, /Total[^0-9]*([0-9.]+)/, m))
      printf "  %5.1fs audio -> %5.1fs  %s\n", aud, m[1]/1000, substr(txt, 1, 44) }
    ' | tail -8
  '';

  hyprwhspr-rs-patched =
    (pkgs.hyprwhspr-rs.override {
      whisper-cpp = whisper-cpp-offload;
    }).overrideAttrs
      (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace src/whisper/manager.rs --replace-fail '"en"' '"ru"'
          substituteInPlace src/input/injector.rs --replace-fail 'tokio::time::sleep(tokio::time::Duration::from_millis(50)).await;' 'tokio::time::sleep(tokio::time::Duration::from_millis(50)).await; let _ = std::process::Command::new("${pkgs.ydotool}/bin/ydotool").env("YDOTOOL_SOCKET", "/run/ydotoold/socket").args(["key", "29:1", "47:1", "47:0", "29:0"]).status(); return Ok(());'
        '';
      });
in
{
  services.hyprwhspr-rs = {
    enable = true;
    #! whisper-cpp vulkan (GPU, no unfree, cached) wrapped for auto nvidia-offload (see whisper-cpp-offload)
    #! two source patches (see postPatch):
    #!   1. force whisper.cpp `--language ru` (upstream hardcodes en, no config knob)
    #!   2. inject via ydotool (uinput) instead of wrtype - Electron/vscode ignores the wayland
    #!      virtual keyboard; text is already on the clipboard, so we just paste it with a real Ctrl+V
    package = hyprwhspr-rs-patched;

  };

  environment.systemPackages = [
    hyprwhspr-rs-patched
    whsprStatus
  ];

  #! the custom (http) provider pipes audio through ffmpeg before uploading - both wav and flac
  #! paths do, despite the error message only naming FLAC - and the unit PATH has no ffmpeg
  systemd.user.services.hyprwhspr-rs.path = [ pkgs.ffmpeg ];

  #! resident whisper model: ~2.2x faster than respawning whisper-cli per dictation
  #! (548M model reloaded every time: ~8.3s vs ~3.7s on the same 6s clip)
  #? started on demand by statusWatch when recording begins, stopped by the idle timer
  #? Restart=always covers a crash or `dgpu_switch_to_integrated/vfio` killing it off the dGPU
  #? (it lsof-kills /dev/nvidia* holders) - it comes back on whatever GPU is available now.
  #? an explicit `systemctl stop` (idle timer) is NOT a restart trigger, so it stays down.
  systemd.user.services.whisper-server = {
    description = "Resident whisper.cpp server for hyprwhspr-rs";
    serviceConfig = {
      ExecStart = "${whisper-cpp-offload}/bin/whisper-server --model ${modelPath} --language ru --host 127.0.0.1 --port ${whisperPort} --threads 8";
      Restart = "always";
      RestartSec = 2;
    };
  };

  #! heartbeat sound while transcribing + on-demand server start (see statusWatch)
  #! also pulled in by hyprwhspr-rs itself: a switch that adds/updates this unit while
  #! graphical-session.target is already active does NOT apply wantedBy retroactively, so
  #! without this the watcher stays dead until the next login (and nothing starts the server)
  systemd.user.services.hyprwhspr-rs.wants = [ "hyprwhspr-status-watch.service" ];

  systemd.user.services.hyprwhspr-status-watch = {
    description = "hyprwhspr-rs status watcher (processing sound, server autostart)";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "hyprwhspr-rs.service" ];
    serviceConfig = {
      ExecStart = statusWatch;
      Restart = "on-failure";
    };
  };

  #! free the model after ${toString whisperIdleSec}s without dictation
  systemd.user.services.whisper-server-idle-stop = {
    description = "Stop whisper-server when idle";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = whisperIdleStop;
    };
  };
  systemd.user.timers.whisper-server-idle-stop = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "1min";
    };
  };

  #? config is read by the daemon from ~/.config/hyprwhspr-rs/config.jsonc
  #? canonical keys live under `transcription.whisper_cpp` (top-level model/whisper_prompt are legacy)
  #? models go to modelsDir, named ggml-<whisperModel>.bin
  # curl -L --create-dirs -o ~/.local/share/hyprwhspr-rs/models/ggml-large-v3-turbo.bin https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin
  # curl -L --create-dirs -o ~/.local/share/hyprwhspr-rs/models/ggml-large-v3-turbo-q5_0.bin https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo-q5_0.bin

  home-manager.users.${username}.xdg.configFile."hyprwhspr-rs/config.jsonc".text = /* json */ ''
    {
      // put final text on clipboard too - unicode-safe fallback
      "auto_copy_clipboard": true,
      // ping-up / ping-down on record start/stop (sounds bundled in the package assets)
      "audio_feedback": true,
      // paste via Shift+Insert instead of Ctrl+V - works in terminals (wezterm) and is cyrillic-safe
      // default Ctrl+V does not paste in terminals, so text never lands there
      "global_paste_shortcut": true,
      // talk to the resident whisper-server instead of respawning whisper-cli (which reloads
      // the model every single time); language is set on the server side (--language ru)
      "transcription": {
        "provider": "custom.local",
        "custom": {
          "local": {
            "kind": "openai_audio_transcriptions",
            "label": "whisper-server",
            "endpoint": "http://127.0.0.1:${whisperPort}/inference",
            "model": "${whisperModel}",
            "audio_format": "wav",
            // initial_prompt: keep program/tech names in latin, russian context
            "prompt": "Расшифровка технической речи на русском. Сохраняй названия программ и технологий латиницей: GitHub, GitLab, Docker, Kubernetes, kubectl, nginx, systemd, Nix, NixOS, Python, Rust, Wayland, niri."
          }
        },
        // kept for fallback: flip provider back to "whisper_cpp" to bypass the server
        "whisper_cpp": {
          "prompt": "Расшифровка технической речи на русском. Сохраняй названия программ и технологий латиницей: GitHub, GitLab, Docker, Kubernetes, kubectl, nginx, systemd, Nix, NixOS, Python, Rust, Wayland, niri.",
          "model": "${whisperModel}",
          "threads": 8,
          "models_dirs": ["${modelsDir}"]
        }
      }
    }
  '';
}
