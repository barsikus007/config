# packages I want to test before adding
{ pkgs, ... }:

with pkgs;
[
  # new base
  dive
  serpl
  busybox
  lshw-gui

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
  # wifite2
  zmap
  rustscan

  helix
  unstable.isd

  # test 2
  meld
  (chromium.override {
    commandLineArgs = [
      "--enable-features=AcceleratedVideoEncoder"
      "--ignore-gpu-blocklist"
      "--enable-zero-copy"
    ];
  })
]
