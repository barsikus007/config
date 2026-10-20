{ pkgs }:
with pkgs;
[
  git
  curl
  wget
  zip
  unzip

  file
  gawk
  which # * ubuntu:-
  procps # watch
  psmisc # fuser killall pstree
  gnused # * ubuntu:sed # * termux:-
  gnugrep # * ubuntu:grep # * termux:-
  openssh # * ubuntu:openssh-client # * termux:-
  iproute2
  iputils # ping tracepath # * ubuntu:iputils-ping iputils-tracepath # * termux: tracepath
  inetutils # ping telnet traceroute whois # * ubuntu:inetutils-telnet inetutils-traceroute whois # * termux: traceroute
  diffutils
  findutils
  netcat-openbsd # nc
]
