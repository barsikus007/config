{ pkgs, ... }:

with pkgs;
[
  jq
  pv
  bat
  duf
  gdu
  fzf
  btop
  neovim
  zoxide
  ripgrep

  ncurses # tput for convinient colors in scripts
]
