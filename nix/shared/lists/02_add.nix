{ pkgs, ... }:
#? add (historicaly, this is packages was unavailable in ubuntu/scoop base repos or have different name)
#! +152Mb to default host
with pkgs;
[
  fd
  eza
  croc
  lsof
  mosh
  tmux
  rsync
  zellij
  tree
  yazi # ? no ubuntu
  starship
  fastfetch
  systemctl-tui
  lazygit
  lazydocker

  zsh
  # fish
  # babelfish
]
