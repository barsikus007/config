{ pkgs, ... }:

with pkgs;
[
  jq
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
