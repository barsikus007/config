{ pkgs, ... }:

with pkgs;
./base.nix
++ [
  # other (specific cli tools)
  uv
  # aria2
  # tldr
  yt-dlp

  # GUI
  mpv
  neovide
]
