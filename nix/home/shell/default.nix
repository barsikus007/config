#! 444Mb
{
  imports = [
    ./minimal.nix

    ./404.nix
    ./neovim.nix
    ./yazi-tui.nix
    { programs.ripgrep-all.enable = true; }
  ];
}
