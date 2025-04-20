# base cli packages, which is used in all hosts and easy to install
{ pkgs, ... }:

with pkgs;
[
  # essential
  git
  curl
  wget

  # base
  mc
  bat
  duf
  gdu
  fzf
  btop
  neovim
  zoxide
  ripgrep

  # add (historicaly, this is packages was unavailable in ubuntu/scoop base repos)
  zsh
  fish
  eza
  lsof
  mosh
  tmux
  tree
  starship
  babelfish
  fastfetch
  lazydocker

  # nix
  nh
  nixfmt-rfc-style
  nixd
  nil
  nix-diff  # TODO: is needed?
]
