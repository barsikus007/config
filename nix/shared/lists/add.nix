{ pkgs, ... }:

with pkgs;
[
  # add (historicaly, this is packages was unavailable in ubuntu/scoop base repos or have different name)
  zsh
  # fish
  # babelfish
  fd
  eza
  lsof
  mosh
  tmux
  zellij
  tree
  yazi
  psmisc # killall pstree
  starship
  fastfetch
  lazygit
  lazydocker
]
