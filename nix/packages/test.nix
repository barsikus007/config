# packages I want to test before adding
{ pkgs, unstable, ... }:

with pkgs;
[
  # new base
  dust
  dive
  dfrs
  serpl
  busybox
  lshw-gui

  # new base filemanagers
  #  yazi is the best rn
  yazi
  nnn
  ranger
  # for tar opening maybe?
  # atool

  # new add
  # tldr
  # tldr-hs
  tlrc
  # tealdeer

  # new add security scanners
  nikto
  # ffuf
  # seclists
  # frida-tools
  # wifite2
  zmap
  rustscan

  helix
  unstable.isd

  # test 2
  wezterm
  cosmic-term
]
