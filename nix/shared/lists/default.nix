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
  android-tools

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
  mpv
  scrcpy
  previous.nekoray
  neovide
  qdirstat
  unstable.vscode-fhs
  keepassxc
  qbittorrent
  # TODO fix && env WEBKIT_DISABLE_COMPOSITING_MODE=1
  unstable.rquickshare-legacy

  # GUI social
  unstable.ayugram-desktop
  element-desktop

  # https://www.reddit.com/r/software/comments/t5n3cm/everything_for_linux/
  fsearch

  # GUI unfree
  obsidian

  # GUI automation
  xclicker
]
