# base cli packages, which is used in all hosts and easy to install
{ pkgs, ... }:

with pkgs;
[
  # essential
  git
  curl
  wget

  # base
  jq
  bat
  duf
  gdu
  fzf
  btop
  neovim
  zoxide
  ripgrep

  # add (historicaly, this is packages was unavailable in ubuntu/scoop base repos or have different name)
  zsh
  fish
  fd
  eza
  lsof
  mosh
  tmux
  tree
  yazi
  starship
  babelfish
  fastfetch
  lazygit
  lazydocker

  # nix
  nh
  nvd
  nix-tree

  nixfmt-rfc-style
  nixd
  nil
]
