# packages I want to test before adding
{ pkgs, ... }:

with pkgs;
[
  # new base
  dive
  serpl
  lshw-gui
  helix
  zellij

  # new add security scanners
  nikto
  # ffuf
  # seclists
  # frida-tools
  # wifite2
  # openvas-scanner
  # burpsuite
  zmap
  rustscan

  # new other
  devenv
  mtr-gui
  dig
  pixelflasher
  qtscrcpy

  # new GUI automation
  autokey
  # ahk_x11
  # ydotool
]
