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
  aria2
  sbctl # for systemd-boot (and lumine) secure boot
  unrar
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
      tkinter
      ptpython
      ipython
      # certifi
    ]
  ))
  unstable.uv
  unstable.hatch
  unstable.ruff

  # CLI node
  bun

  # CLI db
  pgcli
  litecli

  # CLI renders for yazi
  exiftool
  poppler
  resvg
  imagemagick
  ueberzugpp

  # sound
  # for play command for asus
  sox

  # GUI
  gimp3
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
