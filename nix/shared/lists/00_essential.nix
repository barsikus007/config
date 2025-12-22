{ pkgs, ... }:

with pkgs;
[
  git
  curl
  wget

  zip
  gawk
  psmisc # killall pstree
  gnused
  gnugrep
  openssh
  iproute2
  diffutils
  findutils
]
