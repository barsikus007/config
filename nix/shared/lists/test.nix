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
  devbox
  dig
  pixelflasher
  qtscrcpy
  blender

  # new GUI automation
  autokey
  # ahk_x11
]
