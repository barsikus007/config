{ pkgs, ... }:
with pkgs;
(import ./base.nix { inherit pkgs; })
++ [
  # other (specific cli tools)
  gcc
  git-lfs
  isd
  file
  tlrc
  unrar
  aria2
  ffmpeg
  yt-dlp
  pciutils # lspci
  usbutils # lssub
  strace # files monitoring
  inotify-tools # files monitoring

  # CLI python
  python-launcher
  (unstable.python313.withPackages (
    python-pkgs: with python-pkgs; [
      ptpython
      ipython
      # certifi
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
  parsec-bin
  qbittorrent

  # https://www.reddit.com/r/software/comments/t5n3cm/everything_for_linux/
  fsearch

  # GUI unfree
  obsidian

  # GUI automation
  xclicker
]
