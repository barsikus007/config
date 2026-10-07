{
  lib,
  pkgs,
  username,
  ...
}@args:
let
  watchDir = args.watchDir or "/tank/storage/sync/downloads/links";
  downloadsDir = args.downloadsDir or "/tank/storage/sync/downloads";

  link-downloader = pkgs.writeShellApplication {
    name = "link-downloader";
    runtimeInputs = with pkgs; [
      aria2
      coreutils
      ffmpeg-headless
      gnused
      inotify-tools
      yt-dlp
    ];
    #! keep this body ASCII-only: non-ASCII in writeShellApplication trips shellcheck at build time
    text = ''
      watch_dir=${lib.escapeShellArg watchDir}
      downloads_dir=${lib.escapeShellArg downloadsDir}

      mkdir --parents "$watch_dir" "$downloads_dir"

      #? recover interrupted processing files after reboot
      shopt -s nullglob
      for proc in "$watch_dir"/.*.processing; do
        [ -f "$proc" ] || continue
        orig="''${proc#"$watch_dir"/.}"
        orig="''${orig%.processing}"
        mv --force "$proc" "$watch_dir/$orig"
      done
      shopt -u nullglob

      while true; do
        shopt -s nullglob
        files=("$watch_dir"/*)
        shopt -u nullglob

        for file in "''${files[@]}"; do
          [ -f "$file" ] || continue
          filename="''${file##*/}"

          #? ignore hidden and in-progress syncthing sync files
          case "$filename" in
            (.* | *.tmp | *.part | *.crdownload)
              continue
              ;;
          esac

          if [[ "$filename" =~ \.torrent$ ]]; then
            echo "processing torrent file: $file"
            aria2c \
              --dir="$downloads_dir" \
              --max-connection-per-server=8 \
              "$file" || echo "aria2c failed to process torrent: $file"
            rm --force "$file"
            continue
          fi

          #? rename to hidden file to prevent race conditions during sync
          processing_file="$watch_dir/.$filename.processing"
          mv --force "$file" "$processing_file"

          echo "processing links file: $filename"

          while IFS= read -r line || [ -n "$line" ]; do
            url="$(echo "$line" | sed --expression='s/^[[:space:]]*//' --expression='s/[[:space:]]*$//')"

            [ -z "$url" ] && continue
            [[ "$url" =~ ^# ]] && continue

            echo "downloading: $url"

            if [[ "$url" =~ ^magnet: || "$url" =~ \.torrent($|\?) ]]; then
              aria2c \
                --dir="$downloads_dir" \
                --continue=true \
                --auto-file-renaming=true \
                --max-connection-per-server=8 \
                --split=8 \
                --min-split-size=1M \
                "$url" || echo "aria2c failed to download: $url"
            else
              if ! yt-dlp \
                --paths="home:$downloads_dir" \
                --output="%(title)s [%(id)s].%(ext)s" \
                --continue \
                --no-mtime \
                --windows-filenames \
                --no-playlist \
                "$url"; then
                if ! [[ "$url" =~ (youtube\.com|youtu\.be|twitch\.tv|rutube\.ru|vk\.com) ]]; then
                  echo "yt-dlp failed, falling back to aria2c for: $url"
                  aria2c \
                    --dir="$downloads_dir" \
                    --continue=true \
                    --auto-file-renaming=true \
                    --max-connection-per-server=8 \
                    --split=8 \
                    --min-split-size=1M \
                    "$url" || echo "aria2c failed to download: $url"
                else
                  echo "yt-dlp failed to download: $url"
                fi
              fi
            fi
          done < "$processing_file"

          rm --force "$processing_file"
          echo "finished processing and removed: $filename"
        done

        inotifywait \
          --quiet \
          --event=close_write \
          --event=moved_to \
          --timeout=10 \
          "$watch_dir" >/dev/null 2>&1 || true
      done
    '';
  };
in
{
  environment.systemPackages = [ link-downloader ];

  systemd.services.link-downloader = {
    description = "Watch folder link downloader via yt-dlp and aria2c";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    #! wait until ZFS mounts are present
    unitConfig.RequiresMountsFor = [
      watchDir
      downloadsDir
    ];
    serviceConfig = {
      User = username;
      Restart = "always";
      RestartSec = 5;
      WorkingDirectory = downloadsDir;
      ExecStart = lib.getExe link-downloader;
    };
  };
}
