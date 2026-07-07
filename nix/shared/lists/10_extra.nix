{ pkgs, ... }:
with pkgs;
import ./11_powertoys.nix { inherit pkgs; }
++ import ./12_python.nix { inherit pkgs; }
++ [
  #! other (specific cli tools)
  _7zz-rar
  gh
  gcc
  git-lfs
  isd
  file
  prek # ? pre-commit alternative
  tlrc
  aria2
  sbctl # ? for systemd-boot (and lumine) secure boot
  unrar
  yq-go
  ffmpeg
  yt-dlp
  hadolint # ? Dockerfile
  pciutils # ? lspci
  usbutils # ? lssub
  qrencode
  #? files monitoring
  strace
  inotify-tools

  #! CLI node
  bun
  nodejs

  #! CLI db
  lazysql
  pgcli
  litecli

  #! GUI
  gimp3
  scrcpy
  bluetui
  fsearch # ? https://www.reddit.com/r/software/comments/t5n3cm/everything_for_linux/
  neovide
  audacity
  obsidian
  qdirstat
  xclicker
  handbrake
  antimicrox
  parsec-bin
  qbittorrent
  moonlight-qt
]
