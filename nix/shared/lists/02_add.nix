{ pkgs }:
#? add (historicaly, this is packages was unavailable in ubuntu/scoop base repos or have different name)
#! +152Mb to default host
with pkgs;
[
  fd # * ubuntu:fd-find
  bun # * ubuntu:-
  eza
  croc # * ubuntu:-
  lsof
  mosh
  tmux
  zellij # * ubuntu:-
  tree
  yazi # * ubuntu:-
  starship
  fastfetch
  systemctl-tui # * ubuntu:- # * termux:-
  lazygit # * ubuntu:-
  lazydocker # * ubuntu:- # * termux:-

  zsh
]
