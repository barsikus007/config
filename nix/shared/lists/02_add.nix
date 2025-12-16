{ pkgs, ... }:
# add (historicaly, this is packages was unavailable in ubuntu/scoop base repos or have different name)
with pkgs;
[
  fd
  eza
  croc
  lsof
  mosh
  tmux
  zellij
  tree
  yazi
  starship
  fastfetch
  lazygit
  lazydocker

  zsh
  # fish
  # babelfish
]
