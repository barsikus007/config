{ pkgs }:
#? base cli packages, which is used in all hosts and easy to install
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
  nixfmt
  tree-sitter
  tree-sitter-grammars.tree-sitter-nix
])
