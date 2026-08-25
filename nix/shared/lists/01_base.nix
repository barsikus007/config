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
    cudaSupport = true;
    rocmSupport = true;
  })
  neovim
  zoxide
  ripgrep

  ncurses # tput for convinient colors in scripts # * apt:ncurses-bin
  # net-tools # arp
]
