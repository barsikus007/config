{ pkgs }:
with pkgs;
[
  jq
  pv
  bat
  duf
  gdu
  fzf
  (btop.override {
    cudaSupport = pkgs.stdenv.hostPlatform.isx86_64;
    rocmSupport = pkgs.stdenv.hostPlatform.isx86_64;
  })
  neovim
  zoxide
  ripgrep

  ncurses # tput for convinient colors in scripts # * apt:ncurses-bin
  # net-tools # arp
]
