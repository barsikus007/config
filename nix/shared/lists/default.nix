{ pkgs, ... }:
with pkgs;
(import ./base.nix { inherit pkgs; })
++ [
  # other (specific cli tools)
  # aria2
  tlrc
  yt-dlp
  ffmpeg
  unrar
  unstable.isd

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
  nekoray
  neovide
  unstable.vscode-fhs
  keepassxc
  qbittorrent
  # TODO fix && env WEBKIT_DISABLE_COMPOSITING_MODE=1
  unstable.rquickshare-legacy

  # GUI social
  vesktop
  unstable.ayugram-desktop
  element-desktop

  # https://www.reddit.com/r/software/comments/t5n3cm/everything_for_linux/
  fsearch

  # GUI unfree
  (microsoft-edge.override {
    # https://wiki.nixos.org/wiki/Chromium#Accelerated_video_playback
    commandLineArgs = [
      "--enable-features=AcceleratedVideoEncoder"
      "--ignore-gpu-blocklist"
      "--enable-zero-copy"
    ];
  })
  obsidian
]
