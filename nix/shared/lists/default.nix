# base cli packages, which is used in all hosts and easy to install
{ pkgs, ... }:

with pkgs;
import ./essential.nix { inherit pkgs; }
++ import ./base.nix { inherit pkgs; }
++ import ./add.nix { inherit pkgs; }
++ [
  # nix
  nh
  nvd
  nix-tree
  nix-output-monitor

  tree-sitter
  nixfmt-rfc-style
  nixd
  nil
]
