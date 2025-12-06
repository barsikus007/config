{ pkgs, ... }:

with pkgs;
[
  git
  curl
  wget

  gawk
  psmisc # killall pstree
  gnused
  gnugrep
  diffutils
  findutils
]
