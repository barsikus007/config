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
  systemctl-tui

  bruno
  devenv
  devbox
  pixelflasher
  qtscrcpy
  blender
  # (unstable.blender-hip.override {
  #   # blender-hip for rocm amd gpu
  #   cudaSupport = true;
  # })

  # new GUI automation
  autokey
  # ahk_x11
]
