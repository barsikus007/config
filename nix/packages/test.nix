# packages I want to test before adding
{ pkgs, ... }:

with pkgs;
[
  # new base
  dust
  dive
  dfrs
  serpl

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
  zmap
  rustscan
]
