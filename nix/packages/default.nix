{ pkgs, ... }:

with pkgs;
./base.nix
++ [
  # other (specific cli tools)
  uv
  # aria2
  # tldr
  yt-dlp

  # new
  fd
  dust
  dive
  tre
  dfrs
  serpl

  # GUI
  mpv
  neovide
]
