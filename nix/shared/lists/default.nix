{ pkgs, ... }:
with pkgs;
(import ./base.nix { inherit pkgs; })
++ [
  # other (specific cli tools)
  gcc
  git-lfs
  isd
  # aria2
  file
  tlrc
  unrar
  ffmpeg
  yt-dlp
  pciutils # lspci
  usbutils # lssub
  inotify-tools # files monitoring

  # CLI python
  python-launcher
  (unstable.python313.withPackages (
    python-pkgs: with python-pkgs; [
      ptpython
      ipython
    ]
  ))
  unstable.uv
  unstable.hatch
  unstable.ruff

  # CLI db
  pgcli
  litecli

  # CLI renders for yazi
  poppler
  resvg
  imagemagick

  # sound
  # for play command for asus
  sox

  # GUI
  scrcpy
  neovide
  qdirstat
  qbittorrent
  rquickshare-legacy
  # todo ports & ~/.local/share/dev.mandre.rquickshare/.settings.json
  #   {
  #   "realclose": false,
  #   "autostart": true,
  #   "visibility": 0,
  #   "startminimized": true,
  #   "port": 12345
  # }

  # https://www.reddit.com/r/software/comments/t5n3cm/everything_for_linux/
  fsearch

  # GUI unfree
  obsidian

  # GUI automation
  xclicker
]
