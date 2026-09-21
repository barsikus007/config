{ pkgs }:
#? packages I want to test before adding
with pkgs;
[
  #! new base
  ##dive
  serpl
  ast-grep # serpl dep
  lshw-gui

  #? new add security scanners
  nikto
  # ffuf
  # seclists
  # frida-tools
  # openvas-scanner
  # burpsuite
  # caido
  #? nmap alternatives
  zmap
  rustscan
  #? wifi specialised
  mdk4
  wifite2
  airgeddon
  aircrack-ng

  #! networking tools
  iperf
  tcpdump
  wireshark
  bind
  ldns # have drill like dig

  #! new other
  shfmt
  iotop
  fatrace # sudo fatrace . 2>&1 | grep firefox

  yaak
  bruno
  requestly

  devenv
  devbox

  blender
  # TODO: local cache instance
  # (blender.override {
  #   ceres-solver = ceres-solver.override {
  #     cudaSupport = true;
  #     suitesparse = suitesparse.override { enableCuda = true; };
  #   };
  #   cudaSupport = true;
  #   #? no rocm for non-RDNA 2+ GPU
  #   # rocmSupport = true;
  # })

  #! new GUI automation
  autokey
  # ahk_x11

  #! import from obsidian
  broot
  imhex

  lnav
  lazyjournal
]
