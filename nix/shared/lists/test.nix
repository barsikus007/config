# packages I want to test before adding
{ pkgs, ... }:

with pkgs;
[
  # new base
  ##dive
  serpl
  lshw-gui

  #? new add security scanners
  nikto
  # ffuf
  # seclists
  # frida-tools
  # openvas-scanner
  # burpsuite
  # caido
  #? wifi specialised
  mdk4
  wifite2
  airgeddon
  aircrack-ng

  # networking tools
  zmap
  iperf
  tcpdump
  wireshark
  rustscan # nmap
  bind
  ldns # have drill like dig

  # new other
  shfmt
  iotop
  fatrace # sudo fatrace . 2>&1 | grep firefox

  yaak
  bruno
  requestly

  devenv
  devbox

  blender
  # (blender-hip.override {
  #   # blender-hip for rocm amd gpu
  #   cudaSupport = true;
  # })

  # new GUI automation
  autokey
  # ahk_x11
]
