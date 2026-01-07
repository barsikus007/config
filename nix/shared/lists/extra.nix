{ pkgs, ... }:
with pkgs;
[
  # other (specific cli tools)
  _7zz-rar
  gcc
  git-lfs
  isd
  file
  tlrc
  aria2
  sbctl # for systemd-boot (and lumine) secure boot
  unrar
  yq-go
  ffmpeg
  yt-dlp
  pciutils # lspci
  usbutils # lssub
  inetutils # telnet traceroute whois
  rsync
  strace # files monitoring
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
