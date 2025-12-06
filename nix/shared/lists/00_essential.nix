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
  openssh
  iproute2
  diffutils
  findutils
]
