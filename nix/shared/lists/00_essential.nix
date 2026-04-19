{ pkgs, ... }:

with pkgs;
[
  git
  curl
  wget

  zip
  unzip
  gawk
  procps # watch
  psmisc # fuser killall pstree
  gnused
  gnugrep
  openssh
  iproute2
  inetutils # ping telnet traceroute whois
  diffutils
  findutils
  netcat-openbsd # nc
]
