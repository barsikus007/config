{
  imports = [
    ./minimal.nix

    ./404.nix
    { programs.ripgrep-all.enable = true; }
  ];
}
