{ pkgs }:
#? add (historically, these packages were unavailable in ubuntu/scoop base repos or had different names)
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
