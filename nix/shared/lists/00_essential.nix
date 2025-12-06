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
  iproute2
  diffutils
  findutils
]
