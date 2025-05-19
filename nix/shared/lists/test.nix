# packages I want to test before adding
{ pkgs, ... }:

with pkgs;
[
  # new base
  dive
  serpl
  lshw-gui
  helix

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

  # new GUI automation
  autokey
  # ahk_x11
  # ydotool
]
