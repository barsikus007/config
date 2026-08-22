{
  lib,
  pkgs,
  username,
  ...
}:
#! completely vibecoded hyprwhspr-rs integration
#? native speech-to-text dictation (Rust fork), driven by niri keybind -> `record toggle`
#? https://github.com/better-slop/hyprwhspr-rs
let
  #? which engine transcribes: "parakeet" (in-process ONNX) or "whisper" (resident whisper-server)
  #! parakeet-tdt-0.6b-v3 is multilingual (25 langs incl. ru) and auto-detects the language, so
  #! the --language/`"en"` patch below is a whisper-only concern
  #! two things it does NOT have, both of which the whisper path relies on:
  #!   1. no initial_prompt / hotwords - the transducer has no place to put one (the config's
  #!      `parakeet.prompt` is only used to strip prompt echo from the output). So the trick that
  #!      keeps GitHub/kubectl in latin is simply unavailable here - that is what we are testing
  #!   2. no GPU: hyprwhspr-rs calls ParakeetTDT::from_pretrained(dir, None) = CPU execution
  #!      provider, hardcoded. onnxruntime has no vulkan EP either, so overriding it buys nothing
  #? the model is loaded once at daemon start and stays resident (fp32 ~2.5G RSS, int8 ~0.7G)
  asrBackend = "parakeet";
  #? fp32 or int8 - see whspr-fetch-parakeet, re-run it after flipping this
  parakeetVariant = "fp32";

  useWhisperServer = asrBackend == "whisper";

  #? knobs
  #! full v3 (32 decoder layers) beats turbo (4 layers) on technical russian on BOTH gpus, and on
  #! the iGPU it is not even slower - measured on the same 15s clip:
  #!   RTX:  large-v3-q5_0 2.3s "запушь/GitHub/Docker/задеплой/kubectl" | turbo 2.3s "kube.ctl"
  #!   Vega: large-v3-q5_0 10.3s (all terms right) | turbo-f16 10.0s "затеплой" | turbo-q5 8.0s "гитхаб/докер"
  #! resident server on the RTX, full 12-15s recordings, prompt sent (as -rs does): ~1s each, ie
  #! ~15x realtime - large-v3 f16 1.2s/0.9s vs large-v3-q5_0 2.4s/1.8s, same text either way;
  #! f16 needs 3.5G VRAM of the 6G, so nothing else fits alongside; q5_0 takes 1.4G;
  #! cli (no resident model) is much slower: f16 3.7s, q5_0 2.4s on the same clips
  #! NOTE the prompt does the heavy lifting, not the model - without it even f16 writes
  #! "гитхаб/докер/кьюб ctl"; with it, "GitHub/Docker/kubectl" on every model tested
  #? so the same model everywhere; whisperModel stays as the fallback if the other is missing
  # whisperModelNvidia = "large-v3-q5_0";
  whisperModelNvidia = "large-v3";
  whisperModel = "large-v3-q5_0";
  whisperPort = "8765";
  #? initial_prompt: keep program/tech names in latin, russian context
  #! one source for dictation and whspr-file - the wording is load-bearing (see the NOTE above),
  #! so the two must not be allowed to drift apart
  techPrompt = "Расшифровка технической речи на русском. Сохраняй названия программ и технологий латиницей: GitHub, GitLab, Docker, Kubernetes, kubectl, nginx, systemd, Nix, NixOS, Python, Rust, Wayland, niri.";
  #? curl reads the form value from this file, so no cyrillic ends up inside a shell script
  techPromptFile = pkgs.writeText "whspr-tech-prompt" techPrompt;
  #? stop the resident server after this long without a dictation, to release its ~600M
  whisperIdleSec = 300;

  #? hyprwhspr expands `~` itself, but not $HOME - keep the tilde form for its json config
  modelsDir = "~/.local/share/hyprwhspr-rs/models";
  modelsDirAbs = "\${HOME}/.local/share/hyprwhspr-rs/models";
  #? parakeet's model_dir is resolved against the data dir instead, so it stays relative
  parakeetDir = "models/parakeet/parakeet-tdt-0.6b-v3-onnx";
  parakeetDirAbs = "${modelsDirAbs}/parakeet/parakeet-tdt-0.6b-v3-onnx";
  statusFile = "\${HOME}/.cache/hyprwhspr-rs/status.json";
  activityStamp = "\${XDG_RUNTIME_DIR}/hyprwhspr-last-activity";
  #? which GPU the resident server came up on, so a dgpu_switch_* can retrigger it
  gpuStamp = "\${XDG_RUNTIME_DIR}/whisper-server-gpu";

  #! prefer the nvidia dGPU when its driver is loaded, else fall back to the Vega iGPU;
  #! measured on a 6s clip (q5_0): RTX 2060 ~0.3s encode, Vega ~3.2s, plain CPU ~25.5s;
  #! the Max-Q ramps P8 -> P0 on its own during the first run, so no warm-up trick is needed
  #! first run on a cold ~/.cache/nvidia costs ~19s compiling vulkan pipelines (persisted, see
  #! hosts/ROG14/impermanence.nix); mesa/radv recompile fast, so the iGPU shows no such spike
  #? pick by NAME, not by index: vulkan enumeration order changes across dgpu_switch_* (g14.sh),
  #? and __VK_LAYER_NV_optimus=NVIDIA_only no longer reorders anything here
  #? when nvidia is unbound (vfio) it simply is not enumerated, so the grep falls through to AMD
  #! keep model names OUT of this script: it is baked into whisper-cpp-offload, which is an
  #! override input of hyprwhspr-rs - so touching it would rebuild the whole rust package
  #? exports WHISPER_GPU (nvidia|amd) for whoever needs to branch on the chosen device
  pickFastestDevice = pkgs.writeShellScript "whisper-pick-device" /* shell */ ''
    devs=$("${pkgs.whisper-cpp-vulkan}/bin/whisper-cli" --help 2>&1)
    idx=$(printf '%s' "$devs" | ${pkgs.gnugrep}/bin/grep --only-matching --perl-regexp 'ggml_vulkan: \K\d+(?= = .*NVIDIA)' | head -1)
    if [ -n "''${idx:-}" ]; then
      export WHISPER_GPU=nvidia
    else
      idx=$(printf '%s' "$devs" | ${pkgs.gnugrep}/bin/grep --only-matching --perl-regexp 'ggml_vulkan: \K\d+(?= = .*(RADV|AMD|Radeon))' | head -1)
      export WHISPER_GPU=amd
    fi
    [ -n "''${idx:-}" ] && export GGML_VK_VISIBLE_DEVICES="$idx"
  '';

  #? model choice lives here, not in the wrapper, so swapping it never touches hyprwhspr-rs
  #? ExecStart cannot resolve it either: it depends on which GPU is up right now
  whisperServerStart = pkgs.writeShellScript "whisper-server-start" /* shell */ ''
    source ${pickFastestDevice}
    fallback="${modelsDirAbs}/ggml-${whisperModel}.bin"
    if [ "''${WHISPER_GPU:-}" = "nvidia" ]; then
      model="${modelsDirAbs}/ggml-${whisperModelNvidia}.bin"
    else
      model="$fallback"
    fi
    #? never leave the server without a model if the dGPU one was never downloaded
    [ -f "$model" ] || model="$fallback"
    #! stamp the nvidia-presence bit, NOT the picker's verdict: the watcher compares against the
    #! same cheap probe, so a disagreement (driver loaded but vulkan does not enumerate it) can
    #! never turn into a restart loop
    if [ -d /proc/driver/nvidia/gpus ]; then echo nvidia > "${gpuStamp}"; else echo amd > "${gpuStamp}"; fi
    exec "${pkgs.whisper-cpp-vulkan}/bin/whisper-server" \
      --model "$model" --language ru \
      --host 127.0.0.1 --port ${whisperPort} --threads 8
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
        mkdir --parents "$out"
        ffmpeg -f lavfi -i "sine=frequency=520:duration=0.09" \
          -af "afade=t=out:st=0.05:d=0.04,volume=0.22" -ar 48000 "$out/tick.wav"
      '';

  #! -rs writes {class: inactive|active|processing|error} to status.json (atomic, for inotify)
  #! watch it to (a) tick while transcribing - upstream only has start/stop pings, no processing
  #! sound - and (b) spin the resident server up as soon as recording starts, so the model is
  #! already loading while you speak
  statusWatch = pkgs.writeShellScript "hyprwhspr-status-watch" /* shell */ ''
    set -u
    status="${statusFile}"
    stamp="${activityStamp}"
    loop_pid=""
    #? set while WE paused a player, so only our own pause gets undone afterwards
    resumed=""
    stop_loop() {
      if [ -n "$loop_pid" ]; then kill "$loop_pid" 2>/dev/null || true; loop_pid=""; fi
    }
    trap stop_loop EXIT
    react() {
      cls=$(${pkgs.jq}/bin/jq --raw-output '.class // empty' "$status" 2>/dev/null || true)
      case "$cls" in
        active)
          touch "$stamp"
          ${lib.optionalString useWhisperServer /* shell */ ''
            #! the server picks its device ONCE at start, so a dgpu_switch_* while it is up leaves it
            #! transcribing on the old card (and on the old model) - compare against the stamp
            if [ -d /proc/driver/nvidia/gpus ]; then now_gpu=nvidia; else now_gpu=amd; fi
            was_gpu=$(${pkgs.coreutils}/bin/cat "${gpuStamp}" 2>/dev/null || echo "$now_gpu")
            #? --no-block: never stall the watcher on model load
            if [ "$now_gpu" != "$was_gpu" ] && systemctl --user is-active --quiet whisper-server.service; then
              systemctl --user restart --no-block whisper-server.service || true
            else
              systemctl --user start --no-block whisper-server.service || true
            fi
          ''}
          #? hush whatever is playing so it does not bleed into the recording, and remember that
          #? we did - so a player that was already paused is not resumed behind your back
          #! -a/--all-players, else playerctl only ever looks at the first bus name it finds -
          #! an idle chromium instance would mask a firefox that is actually playing
          #? remember the players WE paused, so ones you left paused stay that way
          resumed=$(${pkgs.playerctl}/bin/playerctl --list-all 2>/dev/null | while read -r p; do
            if [ "$(${pkgs.playerctl}/bin/playerctl --player "$p" status 2>/dev/null)" = "Playing" ]; then
              ${pkgs.playerctl}/bin/playerctl --player "$p" pause 2>/dev/null && printf '%s\n' "$p"
            fi
          done)
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
          #? dictation finished (or errored): resume exactly the players we paused
          if [ -n "''${resumed:-}" ]; then
            printf '%s\n' "$resumed" | while read -r p; do
              [ -n "$p" ] && ${pkgs.playerctl}/bin/playerctl --player "$p" play 2>/dev/null || true
            done
            resumed=""
          fi
          stop_loop
          ;;
      esac
    }
    dir=$(${pkgs.coreutils}/bin/dirname "$status")
    ${pkgs.coreutils}/bin/mkdir --parents "$dir"
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
    last=$(${pkgs.coreutils}/bin/stat --format %Y "$stamp" 2>/dev/null || echo 0)
    now=$(${pkgs.coreutils}/bin/date +%s)
    if [ "$((now - last))" -ge ${toString whisperIdleSec} ]; then
      systemctl --user stop whisper-server.service || true
    fi
  '';

  #? `whspr-status` - which GPU the resident server picked + how long recent dictations took
  whsprStatus = pkgs.writeShellScriptBin "whspr-status" /* shell */ ''
    set -u
    echo "== backend: ${asrBackend} =="
    ${lib.optionalString (!useWhisperServer) /* shell */ ''
      v=$(${pkgs.coreutils}/bin/cat "${parakeetDirAbs}/.variant" 2>/dev/null || echo "MISSING - run whspr-fetch-parakeet")
      echo "  parakeet-tdt-0.6b-v3 $v, in-process (CPU only)"
      #? the model is resident in the daemon itself, so its RSS is the whole footprint
      pid=$(systemctl --user show hyprwhspr-rs.service --property MainPID --value 2>/dev/null)
      rss=$(${pkgs.gnugrep}/bin/grep --only-matching --perl-regexp 'VmRSS:\s+\K\d+' "/proc/$pid/status" 2>/dev/null || true)
      [ -n "''${rss:-}" ] && echo "  daemon rss: $((rss / 1024))M"
    ''}
    ${lib.optionalString useWhisperServer /* shell */ ''
      if systemctl --user is-active --quiet whisper-server.service; then
        up=$(systemctl --user show whisper-server.service --property ActiveEnterTimestamp --value)
        #! read the model off the live process: which one got loaded depends on the GPU picked
        #! at start (f16 on the dGPU, quant on the iGPU), so the nix-side default would lie here
        #? read /proc/<MainPID>/cmdline - `ps -C whisper-server` misses it (argv[0] is a store path)
        pid=$(systemctl --user show whisper-server.service --property MainPID --value 2>/dev/null)
        m=$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null \
          | ${pkgs.gnugrep}/bin/grep --only-matching --perl-regexp -- '--model \S*/ggml-\K[^.]+' | head -1)
        echo "  running (since $up), model ''${m:-unknown}, idle-stop ${toString whisperIdleSec}s"
        #? whisper.cpp lists every vulkan device, then logs `using VulkanN` for the one it picked -
        #! resolve N against the list, or you just print the last device it happened to enumerate
        log=$(journalctl --user --unit whisper-server.service --boot --no-pager 2>/dev/null)
        n=$(printf '%s' "$log" | ${pkgs.gnugrep}/bin/grep --only-matching --perl-regexp 'using Vulkan\K\d+' | tail -1)
        if [ -n "''${n:-}" ]; then
          printf '%s' "$log" | ${pkgs.gnugrep}/bin/grep --only-matching --perl-regexp "ggml_vulkan: $n = \K[^|]+" | tail -1 \
            | ${pkgs.gnused}/bin/sed "s/^/  device: [Vulkan$n] /"
        else
          echo "  device: unknown (no vulkan backend line in log)"
        fi
      else
        echo "  stopped (starts on next dictation)"
      fi
      if [ -d /proc/driver/nvidia/gpus ]; then
        echo "  nvidia: driver loaded -> dGPU offload active for new starts"
        #? the watcher restarts the server itself, this only explains a stale device line above
        [ "$(${pkgs.coreutils}/bin/cat "${gpuStamp}" 2>/dev/null || echo nvidia)" = nvidia ] \
          || echo "  card changed since start -> server restarts on the next dictation"
      else
        echo "  nvidia: off/vfio -> falls back to the Vega iGPU"
      fi
    ''}

    echo "== recent dictations =="
    #? -rs logs one benchmark table per dictation; pair audio length with the wall time
    journalctl --user --unit hyprwhspr-rs.service --lines=4000 --no-pager 2>/dev/null | ${pkgs.gawk}/bin/awk '
      /Transcribing/     { if (match($0, /Transcribing ([0-9.]+)s/, a)) aud = a[1] }
      #? local backend logs "Transcription: x", the http one "Transcription (whisper-server): x"
      /✅ Transcription/ { if (match($0, /Transcription[^:]*: (.*)$/, t)) txt = t[1] }
      /│ Total/          { if (match($0, /Total[^0-9]*([0-9.]+)/, m))
      printf "  %5.1fs audio -> %5.1fs  %s\n", aud, m[1]/1000, substr(txt, 1, 44) }
    ' | tail -8
  '';

  #? `whspr-fetch-parakeet [fp32|int8]` - the models are ~2.5G/~0.7G, so they live in the data dir
  #? (bind-mounted to persistent storage, see hosts/ROG14/impermanence.nix), not in the store
  #! parakeet-rs only ever opens encoder-model.onnx / decoder_joint-model.onnx / vocab.txt, so the
  #! quantized pair has to be downloaded UNDER the fp32 names - hence the stamp file, without it
  #! there is no way to tell which variant is actually sitting in the directory
  parakeetFetch = pkgs.writeShellScriptBin "whspr-fetch-parakeet" /* shell */ ''
    set -euo pipefail
    variant="''${1:-${parakeetVariant}}"
    repo=https://huggingface.co/istupakov/parakeet-tdt-0.6b-v3-onnx/resolve/main
    dir="${parakeetDirAbs}"
    stamp="$dir/.variant"

    case "$variant" in
      fp32) enc=encoder-model.onnx; dec=decoder_joint-model.onnx ;;
      int8) enc=encoder-model.int8.onnx; dec=decoder_joint-model.int8.onnx ;;
      *) echo "usage: whspr-fetch-parakeet [fp32|int8]" >&2; exit 1 ;;
    esac

    if [ "$(${pkgs.coreutils}/bin/cat "$stamp" 2>/dev/null || true)" = "$variant" ]; then
      echo "parakeet $variant already in $dir"
      exit 0
    fi

    ${pkgs.coreutils}/bin/mkdir --parents "$dir"
    get() { ${pkgs.curl}/bin/curl --location --fail --progress-bar --output "$dir/$2" "$repo/$1"; }
    get "$enc" encoder-model.onnx
    get "$dec" decoder_joint-model.onnx
    get vocab.txt vocab.txt
    #? fp32 weights do not fit protobuf's 2G limit, so onnx keeps them in a sibling .data file
    if [ "$variant" = fp32 ]; then
      get encoder-model.onnx.data encoder-model.onnx.data
    else
      ${pkgs.coreutils}/bin/rm --force "$dir/encoder-model.onnx.data"
    fi
    echo "$variant" > "$stamp"
    echo "parakeet $variant ready in $dir - restart hyprwhspr-rs.service to load it"
  '';

  #? `whspr-file <audio>...` - run existing files through the same server and prompt as dictation
  #! whisper.cpp's server decodes the upload itself and answers a bare "Invalid request" for
  #! anything it cannot handle (ogg among them), so everything goes through ffmpeg first;
  #! 16k mono s16le is what whisper resamples to anyway
  #? works under either asrBackend: the whisper-server unit stays defined, this just starts it
  whsprFile = pkgs.writeShellScriptBin "whspr-file" /* shell */ ''
    set -euo pipefail
    if [ $# -eq 0 ]; then
      echo "usage: whspr-file <audio-file>..." >&2
      exit 1
    fi

    #? the idle timer fires every minute and stops the server on a stale stamp - keep it fresh,
    #? or a long file loses its server mid-request
    ${pkgs.coreutils}/bin/touch "${activityStamp}"
    systemctl --user start whisper-server.service
    #! the server binds the port only once the model is loaded, so a plain connect IS the readiness
    #! probe; large-v3 on a cold vulkan pipeline cache takes ~20s, hence the generous bound
    i=0
    while ! ${pkgs.curl}/bin/curl --silent --output /dev/null --max-time 2 \
      "http://127.0.0.1:${whisperPort}/"; do
      i=$((i + 1))
      if [ "$i" -ge 60 ]; then
        echo "whisper-server did not come up - check: journalctl --user --unit whisper-server --pager-end" >&2
        exit 1
      fi
      ${pkgs.coreutils}/bin/sleep 1
    done

    tmp=$(${pkgs.coreutils}/bin/mktemp --directory)
    trap '${pkgs.coreutils}/bin/rm --recursive --force "$tmp"' EXIT
    for f in "$@"; do
      if [ $# -gt 1 ]; then echo "== $f =="; fi
      ${pkgs.ffmpeg}/bin/ffmpeg -loglevel error -y -i "$f" \
        -ar 16000 -ac 1 -c:a pcm_s16le "$tmp/in.wav"
      ${pkgs.coreutils}/bin/touch "${activityStamp}"
      ${pkgs.curl}/bin/curl --silent --show-error --max-time 3600 \
        "http://127.0.0.1:${whisperPort}/inference" \
        --form "file=@$tmp/in.wav" \
        --form response_format=json \
        --form "prompt=<${techPromptFile}" \
        | ${pkgs.jq}/bin/jq --raw-output '.text'
      ${pkgs.coreutils}/bin/touch "${activityStamp}"
    done
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
    parakeetFetch
    whsprFile
  ];

  #! the custom (http) provider pipes audio through ffmpeg before uploading - both wav and flac
  #! paths do, despite the error message only naming FLAC - and the unit PATH has no ffmpeg
  systemd.user.services.hyprwhspr-rs.path = [ pkgs.ffmpeg ];

  #! record through the easyeffects chain instead of the raw mic: -rs opens the alsa `default`
  #! node, which bypasses the filters entirely (noise removal etc. measurably help recognition)
  #? cpal has no way to name a pipewire node, but the alsa-pipewire plugin honours PIPEWIRE_NODE
  systemd.user.services.hyprwhspr-rs.environment.PIPEWIRE_NODE = "easyeffects_source";

  #! resident whisper model: ~2.2x faster than respawning whisper-cli per dictation
  #! (548M model reloaded every time: ~8.3s vs ~3.7s on the same 6s clip)
  #? started on demand by statusWatch when recording begins, stopped by the idle timer
  #? Restart=always covers a crash or `dgpu_switch_to_integrated/vfio` killing it off the dGPU
  #? (it lsof-kills /dev/nvidia* holders) - it comes back on whatever GPU is available now
  #? an explicit `systemctl stop` (idle timer) is NOT a restart trigger, so it stays down
  systemd.user.services.whisper-server = {
    description = "Resident whisper.cpp server for hyprwhspr-rs";
    serviceConfig = {
      ExecStart = whisperServerStart;
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
    #! NO `after = hyprwhspr-rs`: combined with the wants above and graphical-session.target that
    #! forms an ordering cycle, and systemd breaks it by dropping the hyprwhspr-rs start job -
    #! ie the daemon silently never comes up. The watcher does not need the ordering anyway:
    #! it creates the cache dir itself and waits for status.json to appear.
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
  #? the units stay defined under parakeet (flipping asrBackend back should be a one-liner),
  #? but nothing starts them: the watcher's start block is compiled out and the timer is unwired
  systemd.user.timers.whisper-server-idle-stop = {
    wantedBy = lib.optionals useWhisperServer [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "1min";
    };
  };

  #? config is read by the daemon from ~/.config/hyprwhspr-rs/config.jsonc
  #? canonical keys live under `transcription.whisper_cpp` (top-level model/whisper_prompt are legacy)
  #? models go to modelsDir, named ggml-<whisperModel>.bin
  # curl --location --create-dirs --output ~/.local/share/hyprwhspr-rs/models/ggml-large-v3-turbo.bin https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin
  # curl --location --create-dirs --output ~/.local/share/hyprwhspr-rs/models/ggml-large-v3-turbo-q5_0.bin https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo-q5_0.bin

  home-manager.users.${username}.xdg.configFile."hyprwhspr-rs/config.jsonc".text = /* json */ ''
    {
      // put final text on clipboard too - unicode-safe fallback
      "auto_copy_clipboard": true,
      // ping-up / ping-down on record start/stop (sounds bundled in the package assets)
      "audio_feedback": true,
      // paste via Shift+Insert instead of Ctrl+V - works in terminals (wezterm) and is cyrillic-safe
      // default Ctrl+V does not paste in terminals, so text never lands there
      "global_paste_shortcut": true,
      // engine is picked by `asrBackend` in the module; both sections stay here either way
      "transcription": {
        "provider": "${if useWhisperServer then "custom.local" else "parakeet"}",
        // in-process NVIDIA Parakeet TDT via ONNX; model_dir is relative to the data dir
        // ("~/.local/share/hyprwhspr-rs"), fetch it with `whspr-fetch-parakeet`
        // `prompt` is deliberately empty: the transducer takes no initial_prompt, this key only
        // strips prompt echo from the output, so the whisper prompt here would be cargo cult
        "parakeet": {
          "model_dir": "${parakeetDir}",
          "prompt": ""
        },
        // the server is started on demand when recording begins, and loading large-v3 takes a
        // few seconds - with the default 2 retries the backoff window is only 0.5+1.0s, so a
        // short dictation could outrun the model load and die on "connection refused";
        // backoff doubles per attempt (500ms << n), so 6 retries covers ~31s of startup
        "max_retries": 6,
        // talk to the resident whisper-server instead of respawning whisper-cli (which reloads
        // the model every single time); language is set on the server side (--language ru)
        "custom": {
          "local": {
            "kind": "openai_audio_transcriptions",
            "label": "whisper-server",
            "endpoint": "http://127.0.0.1:${whisperPort}/inference",
            "model": "${whisperModel}",
            "audio_format": "wav",
            "prompt": "${techPrompt}"
          }
        },
        // kept for fallback: flip provider back to "whisper_cpp" to bypass the server
        "whisper_cpp": {
          "prompt": "${techPrompt}",
          "model": "${whisperModel}",
          "threads": 8,
          "models_dirs": ["${modelsDir}"]
        }
      }
    }
  '';
}
