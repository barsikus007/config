{ pkgs, ... }:

with pkgs;
[
  git
  curl
  wget

  psmisc # killall pstree
  gnused
  gnugrep
]
