{ pkgs, ... }:
with pkgs;
(import ./base.nix { inherit pkgs; })
++ [
  # other (specific cli tools)
  gcc
  git-lfs
  isd
  # aria2
  tlrc
  unrar
  ffmpeg
  yt-dlp
  pciutils # lspci
  usbutils # lssub

  # CLI python
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
  # TODO fix && env WEBKIT_DISABLE_COMPOSITING_MODE=1
  unstable.rquickshare-legacy

  # https://www.reddit.com/r/software/comments/t5n3cm/everything_for_linux/
  fsearch

  # GUI unfree
  obsidian

  # GUI automation
  xclicker
]
