#! 444Mb
{
  imports = [
    ./minimal.nix

    ./404.nix
    ./yazi-tui.nix
    { programs.ripgrep-all.enable = true; }
  ];
}
