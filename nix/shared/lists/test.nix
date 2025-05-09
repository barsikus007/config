# packages I want to test before adding
{ pkgs, ... }:

with pkgs;
[
  # new base
  dive
  serpl
  busybox
  lshw-gui
  lf

  # new add security scanners
  nikto
  # ffuf
  # seclists
  # frida-tools
  # wifite2
  zmap
  rustscan

  helix
  # TODO: unstable 25.05
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
