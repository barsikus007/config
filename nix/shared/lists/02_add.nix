{ pkgs, ... }:
#? add (historicaly, this is packages was unavailable in ubuntu/scoop base repos or have different name)
#! +152Mb to default host
with pkgs;
[
  fd # * apt:fd-find
  eza
  croc # * apt:-
  lsof
  mosh
  tmux
  rsync
  zellij # * apt:-
  tree
  yazi # * apt:-
  starship
  fastfetch
  systemctl-tui # * apt:-
  lazygit # * apt:-
  lazydocker # * apt:-

  zsh
  # fish
  # babelfish
]
