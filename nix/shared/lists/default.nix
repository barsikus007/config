{ pkgs, ... }:
# base cli packages, which is used in all hosts and easy to install
with pkgs;
import ./00_essential.nix { inherit pkgs; }
++ import ./01_base.nix { inherit pkgs; }
++ import ./02_add.nix { inherit pkgs; }
++ [
  # nix
  nh
  nvd
  nix-tree
  nix-output-monitor

  tree-sitter
  tree-sitter-grammars.tree-sitter-nix
  nixfmt
  nixd
  nil
]
