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
  gnused # * apt:sed
  gnugrep # * apt:grep
  openssh # * apt:openssh-client
  iproute2
  iputils # ping tracepath # * apt:iputils-ping iputils-tracepath
  inetutils # ping telnet traceroute whois # * apt:inetutils-telnet inetutils-traceroute whois
  diffutils
  findutils
  netcat-openbsd # nc
]
