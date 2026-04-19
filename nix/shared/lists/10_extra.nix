{ pkgs, ... }:
with pkgs;
import ./11_powertoys.nix { inherit pkgs; }
++ [
  # other (specific cli tools)
  _7zz-rar
  gcc
  git-lfs
  isd
  file
  prek # pre-commit alternative
  tlrc
  aria2
  sbctl # for systemd-boot (and lumine) secure boot
  unrar
  yq-go
  ffmpeg
  yt-dlp
  hadolint # Dockerfile
  pciutils # lspci
  usbutils # lssub
  strace # files monitoring
  qrencode
  inotify-tools # files monitoring

  # CLI python
  python-launcher
  # (python314FreeThreading.withPackages (
  (python3.withPackages (
    python-pkgs: with python-pkgs; [
      tkinter
      ptpython
      ipython
      #? certifi
    ]
  ))
  uv
  hatch
  ruff

  # CLI node
  bun
  nodejs # it is probably installed by other tools anyway

  # CLI db
  lazysql
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
  audacity
  obsidian
  qdirstat
  parsec-bin
  qbittorrent
  moonlight-qt

  # https://www.reddit.com/r/software/comments/t5n3cm/everything_for_linux/
  fsearch

  # GUI automation
  xclicker
]
