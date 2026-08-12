{ pkgs }:
#? base cli packages, which is used in all hosts and easy to install
let
  treefmt-with-config = import ../../treefmt.nix { inherit pkgs; };
in
builtins.concatLists (
  map (pkgsList: import pkgsList { inherit pkgs; }) [
    ./00_essential.nix
    ./01_base.nix
    ./02_add.nix
  ]
)
++ (with pkgs; [
  #? nix
  nvd
  nurl
  nix-tree
  hydra-check
  nixos-anywhere
  nix-output-monitor

  nixd
  tree-sitter
  tree-sitter-grammars.tree-sitter-nix

  treefmt-with-config
  treefmt-with-config.nix-lint
])
