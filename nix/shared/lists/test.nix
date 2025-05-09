# packages I want to test before adding
{ pkgs, ... }:

with pkgs;
[
  # new base
  dive
  serpl
  busybox
  lshw-gui

  # new add security scanners
  nikto
  # ffuf
  # seclists
  # frida-tools
  # wifite2
  zmap
  rustscan

  helix
  # TODO: unstable 25.05
  unstable.isd

  # test 2
  meld
]
