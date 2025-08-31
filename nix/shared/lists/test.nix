# packages I want to test before adding
{ pkgs, ... }:

with pkgs;
[
  # new base
  dive
  serpl
  lshw-gui

  # new add security scanners
  nikto
  # ffuf
  # seclists
  # frida-tools
  # wifite2
  # openvas-scanner
  # burpsuite

  # networking tools
  zmap
  iperf
  rustscan # nmap
  bind
  ldns # have drill like dig

  # new other
  iotop
  psmisc # killall pstree
  fatrace

  bruno
  devenv
  devbox
  pixelflasher
  qtscrcpy
  blender

  # new GUI automation
  autokey
  # ahk_x11
]
