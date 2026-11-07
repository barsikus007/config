{ pkgs, ... }:
#! completely vibecoded hyprwhspr-rs integration
#? native speech-to-text dictation (Rust fork), driven by niri keybind -> `record toggle`
#? https://github.com/better-slop/hyprwhspr-rs
let
  #? fp32 or int8 - see whspr-fetch-parakeet, re-run it after flipping this
  parakeetVariant = "fp32";

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
  defaultConfig = pkgs.writeText "hyprwhspr-config.jsonc" /* json */ ''
    {
      "auto_copy_clipboard": true,
      "audio_feedback": true,
      "global_paste_shortcut": true,
      "transcription": {
        // gemini | parakeet | custom.local
        "provider": "parakeet",
        "request_timeout_secs": 60,
        "max_retries": 2,
        "gemini": {
          "model": "antigravity/gemini-3.8-flash",
          "api_key": "",
          "endpoint": "<cliproxyapi-address>/v1beta/models",
          "temperature": 0.0,
          "max_output_tokens": 1024,
          "prompt": "${techPrompt}"
        },
        "groq": {
          "model": "whisper-large-v3-turbo",
          "api_key": "",
          "endpoint": "https://api.groq.com/openai/v1/audio/transcriptions",
          "prompt": "${techPrompt}"
        },
        "parakeet": {
          "model_dir": "models/parakeet/parakeet-tdt-0.6b-v3-onnx",
          "prompt": ""
        },
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
        "whisper_cpp": {
          "prompt": "${techPrompt}",
          "model": "${whisperModel}",
          "threads": 8,
          "models_dirs": ["~/.local/share/hyprwhspr-rs/models"]
        }
      }
    }
  '';
  initConfig = pkgs.writeShellScript "hyprwhspr-init-config" ''
    config_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/hyprwhspr-rs"
    ${pkgs.coreutils}/bin/mkdir --parents "$config_dir"
    config_file="$config_dir/config.jsonc"
    if [ -e "$config_file" ] || [ -L "$config_file" ]; then exit 0; fi
    umask 077
    set -o noclobber
    ${pkgs.coreutils}/bin/cat ${defaultConfig} > "$config_file"
  '';
  #? stop the resident server after this long without a dictation, to release its ~600M
  whisperIdleSec = 300;

  modelsDirAbs = "\${HOME}/.local/share/hyprwhspr-rs/models";
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
  pickFastestDevice = pkgs.writeShellScript "whisper-pick-device" ''
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
  whisperServerStart = pkgs.writeShellScript "whisper-server-start" ''
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
  statusWatch = pkgs.writeShellScript "hyprwhspr-status-watch" ''
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
        (active)
          touch "$stamp"
          prov=$(${pkgs.jq}/bin/jq --raw-output '.transcription.provider // empty' "$HOME/.config/hyprwhspr-rs/config.jsonc" 2>/dev/null || true)
          if [ "$prov" = "custom.local" ] || [ "$prov" = "whisper_cpp" ]; then
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
          fi
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
        (processing)
          touch "$stamp"
          if [ -z "$loop_pid" ] || ! kill -0 "$loop_pid" 2>/dev/null; then
            ( while true; do ${pkgs.pipewire}/bin/pw-play "${processingTick}/tick.wav"; sleep 0.4; done ) &
            loop_pid=$!
          fi
          ;;
        (*)
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
  whisperIdleStop = pkgs.writeShellScript "whisper-server-idle-stop" ''
    set -u
    stamp="${activityStamp}"
    last=$(${pkgs.coreutils}/bin/stat --format %Y "$stamp" 2>/dev/null || echo 0)
    now=$(${pkgs.coreutils}/bin/date +%s)
    if [ "$((now - last))" -ge ${toString whisperIdleSec} ]; then
      systemctl --user stop whisper-server.service || true
    fi
  '';

  #? `whspr-status` - which GPU the resident server picked + how long recent dictations took
  whsprStatus = pkgs.writeShellScriptBin "whspr-status" ''
    set -u
    cfg="$HOME/.config/hyprwhspr-rs/config.jsonc"
    prov=$(${pkgs.jq}/bin/jq --raw-output '.transcription.provider // empty' "$cfg" 2>/dev/null || echo "unknown")
    echo "== backend: $prov =="
    case "$prov" in
      (parakeet)
        v=$(${pkgs.coreutils}/bin/cat "${parakeetDirAbs}/.variant" 2>/dev/null || echo "MISSING - run whspr-fetch-parakeet")
        echo "  parakeet-tdt-0.6b-v3 $v, in-process (CPU only)"
        #? the model is resident in the daemon itself, so its RSS is the whole footprint
        pid=$(systemctl --user show hyprwhspr-rs.service --property MainPID --value 2>/dev/null)
        rss=$(${pkgs.gnugrep}/bin/grep --only-matching --perl-regexp 'VmRSS:\s+\K\d+' "/proc/$pid/status" 2>/dev/null || true)
        [ -n "''${rss:-}" ] && echo "  daemon rss: $((rss / 1024))M"
        ;;
      (gemini)
        m=$(${pkgs.jq}/bin/jq --raw-output '.transcription.gemini.model // "unknown"' "$cfg" 2>/dev/null || echo "unknown")
        ep=$(${pkgs.jq}/bin/jq --raw-output '.transcription.gemini.endpoint // "unknown"' "$cfg" 2>/dev/null || echo "unknown")
        echo "  model: $m"
        echo "  endpoint: $ep"
        ;;
      (groq)
        m=$(${pkgs.jq}/bin/jq --raw-output '.transcription.groq.model // "unknown"' "$cfg" 2>/dev/null || echo "unknown")
        ep=$(${pkgs.jq}/bin/jq --raw-output '.transcription.groq.endpoint // "unknown"' "$cfg" 2>/dev/null || echo "unknown")
        echo "  model: $m"
        echo "  endpoint: $ep"
        ;;
      (custom.local|whisper_cpp)
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
        ;;
    esac

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
  parakeetFetch = pkgs.writeShellScriptBin "whspr-fetch-parakeet" ''
    set -euo pipefail
    variant="''${1:-${parakeetVariant}}"
    repo=https://huggingface.co/istupakov/parakeet-tdt-0.6b-v3-onnx/resolve/main
    dir="${parakeetDirAbs}"
    stamp="$dir/.variant"

    case "$variant" in
      (fp32) enc=encoder-model.onnx; dec=decoder_joint-model.onnx ;;
      (int8) enc=encoder-model.int8.onnx; dec=decoder_joint-model.int8.onnx ;;
      (*) echo "usage: whspr-fetch-parakeet [fp32|int8]" >&2; exit 1 ;;
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
  whsprFile = pkgs.writeShellScriptBin "whspr-file" ''
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

  geminiOpenAiRs = pkgs.writeText "gemini.rs" /* rust */ ''
    use crate::config::GeminiConfig;
    use crate::transcription::audio::{encode_to_wav, EncodedAudio};
    use crate::transcription::postprocess::clean_transcription;
    use crate::transcription::{BackendMetrics, TranscriptionResult};
    use anyhow::{Context, Result};
    use base64::engine::general_purpose::STANDARD as BASE64;
    use base64::Engine;
    use reqwest::{Client, Url};
    use serde::{Deserialize, Serialize};
    use std::cmp;
    use std::time::{Duration, Instant};
    use tokio::time::sleep;
    use tracing::{info, warn};

    #[derive(Clone)]
    pub struct GeminiTranscriber {
        client: Client,
        endpoint: Url,
        api_key: String,
        prompt: String,
        #[allow(dead_code)]
        temperature: f32,
        #[allow(dead_code)]
        max_output_tokens: u32,
        model: String,
        request_timeout: Duration,
        max_retries: u32,
    }

    impl GeminiTranscriber {
        pub fn new(
            api_key: String,
            config: &GeminiConfig,
            request_timeout: Duration,
            max_retries: u32,
            prompt: String,
        ) -> Result<Self> {
            let endpoint = resolve_endpoint(&config.endpoint)?;

            let client = Client::builder()
                .user_agent("hyprwhspr-rs (gemini-openai)")
                .connect_timeout(Duration::from_secs(10))
                .timeout(request_timeout)
                .pool_idle_timeout(Duration::from_secs(30))
                .build()
                .context("Failed to build Gemini HTTP client")?;

            Ok(Self {
                client,
                endpoint,
                api_key,
                prompt,
                temperature: config.temperature,
                max_output_tokens: config.max_output_tokens,
                model: config.model.clone(),
                request_timeout,
                max_retries,
            })
        }

        pub fn initialize(&self) -> Result<()> {
            if self.api_key.trim().is_empty() {
                anyhow::bail!("api_key in config or GEMINI_API_KEY is required to use the Gemini transcription backend");
            }

            info!(
                "✅ Gemini transcription ready (model: {}, endpoint: {}, timeout: {:?})",
                self.model, self.endpoint, self.request_timeout
            );
            Ok(())
        }

        pub fn provider_name(&self) -> &'static str {
            "Gemini"
        }

        pub async fn transcribe(&self, audio_data: Vec<f32>) -> Result<TranscriptionResult> {
            if audio_data.is_empty() {
                return Ok(TranscriptionResult {
                    text: String::new(),
                    metrics: BackendMetrics::default(),
                });
            }

            let duration_secs = audio_data.len() as f32 / 16000.0;
            info!(
                provider = self.provider_name(),
                "🧠 Transcribing {:.2}s of audio via Gemini (OpenAI chat completions)", duration_secs
            );

            let encode_start = Instant::now();
            let encoded = encode_to_wav(&audio_data).await?;
            let audio_payload = BASE64.encode(encoded.data.as_ref());
            let encode_duration = encode_start.elapsed();
            let payload_bytes = audio_payload.len();

            let transcribe_start = Instant::now();
            let (raw, timings) = self.send_with_retry(&encoded, &audio_payload).await?;
            let transcription_duration = transcribe_start.elapsed();
            let cleaned = clean_transcription(&raw, &self.prompt);

            if cleaned.is_empty() {
                warn!("Gemini returned empty or non-speech transcription");
            } else {
                info!("✅ Transcription (Gemini): {}", cleaned);
            }

            let metrics = BackendMetrics {
                encode_duration: Some(encode_duration),
                encoded_bytes: Some(payload_bytes),
                upload_duration: Some(timings.upload),
                response_duration: Some(timings.response),
                transcription_duration,
                phases: Vec::new(),
            };

            Ok(TranscriptionResult {
                text: cleaned,
                metrics,
            })
        }

        async fn send_with_retry(
            &self,
            audio: &EncodedAudio,
            payload: &str,
        ) -> Result<(String, NetworkTimings)> {
            let attempts = cmp::max(1, self.max_retries.saturating_add(1));

            for attempt in 0..attempts {
                match self.send_once(audio, payload).await {
                    Ok(result) => return Ok(result),
                    Err(err) => {
                        if attempt + 1 == attempts {
                            return Err(err);
                        }

                        warn!(
                            attempt = attempt + 1,
                            max_attempts = attempts,
                            "Gemini transcription attempt failed: {}",
                            err
                        );

                        let backoff = Duration::from_millis(600 * (1 << attempt));
                        sleep(backoff).await;
                    }
                }
            }

            Err(anyhow::anyhow!("Unknown Gemini transcription failure"))
        }

        async fn send_once(
            &self,
            _audio: &EncodedAudio,
            payload: &str,
        ) -> Result<(String, NetworkTimings)> {
            let instruction = build_instruction(&self.prompt);

            let body = OpenAiChatRequest {
                model: &self.model,
                messages: vec![OpenAiMessage {
                    role: "user",
                    content: vec![
                        OpenAiContentPart::Text { text: &instruction },
                        OpenAiContentPart::InputAudio {
                            input_audio: InputAudio {
                                data: payload,
                                format: "wav",
                            },
                        },
                    ],
                }],
            };

            let request_start = Instant::now();
            let mut request = self.client.post(self.endpoint.clone()).json(&body);

            let token = self.api_key.trim();
            let token = token
                .strip_prefix("Bearer ")
                .or_else(|| token.strip_prefix("bearer "))
                .unwrap_or(token)
                .trim();
            if !token.is_empty() {
                request = request.bearer_auth(token);
            }

            let response = request
                .send()
                .await
                .context("Failed to send OpenAI chat completions transcription request")?;

            let upload_duration = request_start.elapsed();

            if response.status().is_success() {
                let parse_start = Instant::now();
                let payload: OpenAiChatResponse = response
                    .json()
                    .await
                    .context("Failed to deserialize OpenAI chat completions response")?;
                let response_duration = parse_start.elapsed();
                let text = extract_text(payload).unwrap_or_default();
                return Ok((
                    text,
                    NetworkTimings {
                        upload: upload_duration,
                        response: response_duration,
                    },
                ));
            }

            let status = response.status();
            let raw_body = response.text().await.unwrap_or_default();
            let message = serde_json::from_str::<OpenAiErrorResponse>(&raw_body)
                .ok()
                .and_then(|err_resp| err_resp.error)
                .and_then(|err| err.message)
                .unwrap_or_else(|| {
                    if raw_body.trim().is_empty() {
                        format!("Gemini transcription failed with status {status}")
                    } else {
                        raw_body
                    }
                });

            Err(anyhow::anyhow!(message).context(format!("Gemini request failed ({status})")))
        }
    }

    #[derive(Debug, Clone, Copy)]
    struct NetworkTimings {
        upload: Duration,
        response: Duration,
    }

    fn build_instruction(prompt: &str) -> String {
        let mut instruction = String::from(
            "You are a dedicated speech-to-text engine. Return only the verbatim transcription of the provided audio.\n",
        );

        if !prompt.trim().is_empty() {
            instruction.push_str("\nTranscription style guidance: ");
            instruction.push_str(prompt.trim());
        }

        instruction
    }

    fn resolve_endpoint(raw: &str) -> Result<Url> {
        let trimmed = raw.trim().trim_end_matches('/');
        let target = if let Some(base) = trimmed.strip_suffix("/v1beta/models") {
            format!("{base}/v1/chat/completions")
        } else if let Some(base) = trimmed.strip_suffix("/v1beta") {
            format!("{base}/v1/chat/completions")
        } else if trimmed.ends_with("/chat/completions") {
            trimmed.to_string()
        } else if let Some(base) = trimmed.strip_suffix("/v1") {
            format!("{base}/v1/chat/completions")
        } else {
            format!("{trimmed}/v1/chat/completions")
        };
        Url::parse(&target)
            .with_context(|| format!("Invalid OpenAI chat completions endpoint: {target} (from {raw})"))
    }

    fn extract_text(response: OpenAiChatResponse) -> Option<String> {
        response
            .choices
            .into_iter()
            .flatten()
            .find_map(|choice| {
                choice.message.and_then(|msg| match msg.content {
                    Some(ResponseContent::Text(text)) => Some(text),
                    Some(ResponseContent::Parts(parts)) => {
                        let combined: String = parts
                            .into_iter()
                            .filter_map(|p| p.text)
                            .collect::<Vec<_>>()
                            .join("");
                        if combined.is_empty() {
                            None
                        } else {
                            Some(combined)
                        }
                    }
                    None => None,
                })
            })
    }

    #[derive(Serialize)]
    struct OpenAiChatRequest<'a> {
        model: &'a str,
        messages: Vec<OpenAiMessage<'a>>,
    }

    #[derive(Serialize)]
    struct OpenAiMessage<'a> {
        role: &'static str,
        content: Vec<OpenAiContentPart<'a>>,
    }

    #[derive(Serialize)]
    #[serde(tag = "type")]
    enum OpenAiContentPart<'a> {
        #[serde(rename = "text")]
        Text { text: &'a str },
        #[serde(rename = "input_audio")]
        InputAudio { input_audio: InputAudio<'a> },
    }

    #[derive(Serialize)]
    struct InputAudio<'a> {
        data: &'a str,
        format: &'static str,
    }

    #[derive(Debug, Deserialize, Default)]
    struct OpenAiChatResponse {
        choices: Option<Vec<OpenAiChoice>>,
    }

    #[derive(Debug, Deserialize)]
    struct OpenAiChoice {
        message: Option<OpenAiResponseMessage>,
    }

    #[derive(Debug, Deserialize)]
    #[serde(untagged)]
    enum ResponseContent {
        Text(String),
        Parts(Vec<ResponseContentPart>),
    }

    #[derive(Debug, Deserialize)]
    struct ResponseContentPart {
        text: Option<String>,
    }

    #[derive(Debug, Deserialize)]
    struct OpenAiResponseMessage {
        content: Option<ResponseContent>,
    }

    #[derive(Debug, Deserialize, Default)]
    struct OpenAiErrorResponse {
        error: Option<OpenAiErrorDetail>,
    }

    #[derive(Debug, Deserialize)]
    struct OpenAiErrorDetail {
        message: Option<String>,
    }
  '';

  hyprwhspr-rs-patched =
    (pkgs.hyprwhspr-rs.override {
      whisper-cpp = whisper-cpp-offload;
    }).overrideAttrs
      (previousAttrs: {
        doCheck = false;
        postPatch = (previousAttrs.postPatch or "") + ''
          cp ${geminiOpenAiRs} src/transcription/gemini.rs
          substituteInPlace src/config.rs \
            --replace-fail 'pub max_output_tokens: u32,' 'pub max_output_tokens: u32, pub api_key: String,' \
            --replace-fail 'max_output_tokens: default_gemini_max_output_tokens(),' 'max_output_tokens: default_gemini_max_output_tokens(), api_key: String::new(),' \
            --replace-fail 'endpoint: default_groq_endpoint(),' 'endpoint: default_groq_endpoint(), api_key: String::new(),' \
            --replace-fail 'pub struct GroqConfig {' 'pub struct GroqConfig { pub api_key: String,'
          substituteInPlace src/transcription/mod.rs \
            --replace-fail 'let api_key = env::var("GEMINI_API_KEY")' 'let api_key = if !config.transcription.gemini.api_key.trim().is_empty() { config.transcription.gemini.api_key.clone() } else { env::var("GEMINI_API_KEY")' \
            --replace-fail '.context("GEMINI_API_KEY environment variable is not set")?;' '.unwrap_or_default() };' \
            --replace-fail 'let api_key = env::var("GROQ_API_KEY")' 'let api_key = if !config.transcription.groq.api_key.trim().is_empty() { config.transcription.groq.api_key.clone() } else { env::var("GROQ_API_KEY")' \
            --replace-fail '.context("GROQ_API_KEY environment variable is not set")?;' '.unwrap_or_default() };'
          substituteInPlace src/transcription/groq.rs \
            --replace-fail 'GROQ_API_KEY is required' 'api_key in config or GROQ_API_KEY is required'
          substituteInPlace src/whisper/manager.rs --replace-fail '"en"' '"ru"'
          substituteInPlace src/input/injector.rs --replace-fail 'debug!("Text copied to Wayland clipboard");' 'debug!("Text copied to Wayland clipboard"); return Ok(());'
          substituteInPlace src/input/injector.rs --replace-fail 'tokio::time::sleep(tokio::time::Duration::from_millis(50)).await;' 'tokio::time::sleep(tokio::time::Duration::from_millis(50)).await; let _ = std::process::Command::new("${pkgs.ydotool}/bin/ydotool").env("YDOTOOL_SOCKET", "/run/ydotoold/socket").args(["key", "29:1", "47:1", "47:0", "29:0"]).status(); return Ok(());'
        '';
      });
in
{
  services.hyprwhspr-rs = {
    enable = true;
    #! whisper-cpp vulkan (GPU, no unfree, cached) wrapped for auto nvidia-offload (see whisper-cpp-offload)
    #! four source patches (see postPatch):
    #!   1. force whisper.cpp `--language ru` (upstream hardcodes en, no config knob)
    #!   2. return early on successful wayland copy - upstream forgot return Ok(()), running arboard
    #!      right after and cancelling the first offer (causing race/lost clipboard in noctalia)
    #!   3. inject via ydotool (uinput) instead of wrtype - Electron/vscode ignores the wayland
    #!      virtual keyboard; text is already on the clipboard, so we just paste it with a real Ctrl+V
    #!   4. gemini backend: openai chat completions format with audio input, bearer auth
    package = hyprwhspr-rs-patched;

  };

  custom.persist.home.directories = [ ".config/hyprwhspr-rs" ];

  environment.systemPackages = [
    hyprwhspr-rs-patched
    whsprStatus
    parakeetFetch
    whsprFile
  ];

  #! the custom (http) provider pipes audio through ffmpeg before uploading - both wav and flac
  #! paths do, despite the error message only naming FLAC - and the unit PATH has no ffmpeg
  systemd.user.services.hyprwhspr-rs.path = [ pkgs.ffmpeg ];
  systemd.user.services.hyprwhspr-rs.serviceConfig.ExecStartPre = initConfig;

  #! record through the easyeffects chain instead of the raw mic: -rs opens the alsa `default`
  #! node, which bypasses the filters entirely (noise removal etc. measurably help recognition)
  #? cpal has no way to name a pipewire node, but the alsa-pipewire plugin honours PIPEWIRE_NODE
  systemd.user.services.hyprwhspr-rs.environment.PIPEWIRE_NODE = "easyeffects_source";
  systemd.user.services.hyprwhspr-rs.serviceConfig.EnvironmentFile = "-%h/.config/hyprwhspr-rs/env";

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
  systemd.user.timers.whisper-server-idle-stop = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "1min";
    };
  };

  #? config is read by the daemon from ~/.config/hyprwhspr-rs/config.jsonc
  #? models go to modelsDir, named ggml-<whisperModel>.bin
  # curl --location --create-dirs --output ~/.local/share/hyprwhspr-rs/models/ggml-large-v3-turbo.bin https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin
  # curl --location --create-dirs --output ~/.local/share/hyprwhspr-rs/models/ggml-large-v3-turbo-q5_0.bin https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo-q5_0.bin
}
