{ pkgs, ... }:

with pkgs;
[
  git
  curl
  wget

  zip
  gawk
  procps # watch
  psmisc # killall pstree
  gnused
  gnugrep
  openssh
  iproute2
  inetutils # ping telnet traceroute whois
  diffutils
  findutils
]
