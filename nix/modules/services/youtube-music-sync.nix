{
  lib,
  pkgs,
  username,
  ...
}@args:
let
  srcRoot = args.srcRoot or "/tank/storage/downloads/media/youtube/video";
  dstRoot = args.dstRoot or "/tank/storage/sync/music";
  onCalendar = args.onCalendar or "daily";
  #? collections that are not music, skipped on conversion; whatever they already
  #? produced stays put, since pruning only reacts to a vanished source video
  excludeCollections = args.excludeCollections or [ "CUM_COLLECTION" ];

  findExclude = lib.concatMapStringsSep " " (
    collection: "-not -path ${lib.escapeShellArg "*/${collection}/*"}"
  ) excludeCollections;

  youtube-music-sync = pkgs.writeShellApplication {
    name = "youtube-music-sync";
    runtimeInputs = with pkgs; [
      coreutils
      diffutils
      ffmpeg
      findutils
      jq
      opustags
    ];
    #! keep this body ASCII-only: non-ASCII in writeShellApplication trips shellcheck at build time
    text = /* shell */ ''
      src_root=${lib.escapeShellArg srcRoot}
      dst_root=${lib.escapeShellArg dstRoot}

      #? one track per invocation, re-entered through xargs for parallelism
      convert_one() {
        local mkv="$1"
        local collection base out out_dir cover codec tmp
        local acodec=()

        collection="$(basename "$(dirname "$mkv")")"
        base="$(basename "$mkv" .mkv)"
        out_dir="$dst_root/$collection"
        out="$out_dir/$base.opus"
        cover="''${mkv%.mkv}.jpg"

        if [ -f "$out" ] && [ "$out" -nt "$mkv" ] &&
          { [ ! -f "$cover" ] || [ "$out" -nt "$cover" ]; }; then
          return 0
        fi

        mkdir --parents "$out_dir"
        tmp="$out.tmp.$$"
        #? a partial file left behind would look "done" to the next run
        trap 'rm --force -- "''${tmp:-}"' EXIT

        codec="$(ffprobe -v error -select_streams a:0 \
          -show_entries stream=codec_name -of default=nw=1:nk=1 "$mkv" || true)"
        if [ "$codec" = opus ]; then
          acodec=(-c:a copy)
        else
          acodec=(-c:a libopus -b:a 160k)
        fi

        #? -f opus is required: the temp name carries no extension ffmpeg can guess from
        if ! ffmpeg -nostdin -y -v error -i "$mkv" -vn -map_metadata 0 \
          -metadata "ALBUM=$collection" "''${acodec[@]}" -f opus "$tmp"; then
          rm --force -- "$tmp"
          echo "FAILED $collection/$base" >&2
          return 0
        fi

        #? ffmpeg cannot mux a picture into Ogg, so the cover goes in as METADATA_BLOCK_PICTURE
        #? opustags warns about control characters in youtube descriptions, only the status matters
        if [ -f "$cover" ] && ! opustags --in-place --set-cover "$cover" "$tmp"; then
          echo "FAILED-COVER $collection/$base" >&2
        fi

        mv --force -- "$tmp" "$out"
        echo "CONVERTED $collection/$base"
      }

      if [ "''${1:-}" = "--convert-one" ]; then
        convert_one "$2"
        exit 0
      fi

      #? outputs whose source video is gone, then collections that lost every track
      prune_removed() {
        local out rel name removed=0
        [ -d "$dst_root" ] || return 0

        while IFS= read -r -d "" out; do
          rel="''${out#"$dst_root"/}"
          if [ ! -f "$src_root/''${rel%.opus}.mkv" ]; then
            rm --force -- "$out"
            removed=$((removed + 1))
          fi
        done < <(find "$dst_root" -mindepth 2 -maxdepth 2 -type f -name '*.opus' -print0)

        #! a SIGKILLed run (an OOM kill, say) never reaches the EXIT trap, so partial
        #! files survive; conversion is over by now, none of these can still be in use
        find "$dst_root" -mindepth 2 -maxdepth 2 -type f -name '*.opus.tmp.*' -delete

        #! -not -name '.*' keeps syncthing markers such as .stfolder alive
        find "$dst_root" -mindepth 1 -maxdepth 1 -type d -not -name '.*' -empty -delete

        #? a playlist outlives its collection only when the whole collection disappears
        while IFS= read -r -d "" pl; do
          name="$(basename "$pl" .m3u8)"
          if [ "$name" != all ] && [ ! -d "$dst_root/$name" ]; then
            rm --force -- "$pl"
          fi
        done < <(find "$dst_root" -mindepth 1 -maxdepth 1 -type f -name '*.m3u8' -print0)

        echo "$removed"
      }

      playlist_entries() {
        local collection="$1"
        local f base json dur title artist

        while IFS= read -r -d "" f; do
          base="$(basename "$f" .opus)"
          json="$src_root/$collection/$base.info.json"
          dur=-1
          title="$base"
          artist=""
          if [ -f "$json" ]; then
            dur="$(jq --raw-output '(.duration // 0) | floor' "$json")"
            title="$(jq --raw-output '.title // ""' "$json")"
            artist="$(jq --raw-output '.uploader // ""' "$json")"
          fi
          if [ -n "$artist" ]; then
            printf '#EXTINF:%s,%s - %s\n' "$dur" "$artist" "$title"
          else
            printf '#EXTINF:%s,%s\n' "$dur" "$title"
          fi
          printf '%s/%s\n' "$collection" "$(basename "$f")"
        done < <(find "$dst_root/$collection" -maxdepth 1 -type f -name '*.opus' -print0 |
          sort --zero-terminated)
      }

      #? swap only on a real change, else syncthing re-sends every playlist on every run
      install_playlist() {
        local target="$1" tmp="$2"
        if [ -f "$target" ] && cmp --quiet "$tmp" "$target"; then
          rm --force -- "$tmp"
          return 1
        fi
        mv --force -- "$tmp" "$target"
        return 0
      }

      write_playlists() {
        local dir collection tmp all_tmp written=0
        #? a killed run leaves temps behind, and syncthing would happily ship them to peers
        rm --force -- "$dst_root"/.m3u8.*
        all_tmp="$(mktemp "$dst_root/.m3u8.XXXXXX")"
        echo "#EXTM3U" >"$all_tmp"

        while IFS= read -r -d "" dir; do
          collection="$(basename "$dir")"
          tmp="$(mktemp "$dst_root/.m3u8.XXXXXX")"
          {
            echo "#EXTM3U"
            playlist_entries "$collection"
          } >"$tmp"
          tail --lines=+2 "$tmp" >>"$all_tmp"
          if install_playlist "$dst_root/$collection.m3u8" "$tmp"; then
            written=$((written + 1))
          fi
        done < <(find "$dst_root" -mindepth 1 -maxdepth 1 -type d -not -name '.*' -print0 |
          sort --zero-terminated)

        if install_playlist "$dst_root/all.m3u8" "$all_tmp"; then
          written=$((written + 1))
        fi

        echo "$written"
      }

      total="$(find "$src_root" -mindepth 2 -maxdepth 2 -type f -name '*.mkv' ${findExclude} \
        -printf 'x' | wc --bytes)"

      #! bail before pruning: an unmounted or empty source would otherwise read as
      #! "every track was deleted upstream" and wipe the whole library
      if [ "$total" -eq 0 ]; then
        echo "no source videos under $src_root, refusing to prune" >&2
        exit 1
      fi

      mkdir --parents "$dst_root"

      converted="$(find "$src_root" -mindepth 2 -maxdepth 2 -type f -name '*.mkv' ${findExclude} \
        -print0 |
        xargs --null --no-run-if-empty --max-procs="$(nproc)" --max-args=1 "$0" --convert-one |
        grep --count '^CONVERTED ' || true)"
      removed="$(prune_removed)"
      playlists="$(write_playlists)"

      echo "converted $converted, skipped $((total - converted)), removed $removed, playlists rewritten $playlists"
    '';
  };
in
{
  environment.systemPackages = [ youtube-music-sync ];

  systemd.services.youtube-music-sync = {
    description = "Convert tubesync videos into an audio library with covers and playlists";
    #! without this a boot-time catch-up run could start before the zfs mounts and
    #! see an empty source tree
    unitConfig.RequiresMountsFor = [
      srcRoot
      dstRoot
    ];
    serviceConfig = {
      Type = "oneshot";
      User = username;
      ExecStart = lib.getExe youtube-music-sync;
      Nice = 19;
      IOSchedulingClass = "idle";
    };
  };

  systemd.timers.youtube-music-sync = {
    description = "Periodic tubesync to music library conversion";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = onCalendar;
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
  };
}
