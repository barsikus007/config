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
  zmap
  rustscan
]
