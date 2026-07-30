{ custom, ... }:
{
  imports = [
    ../../shared/options.nix

    ../../home
    ../../home/shell
    ../../home/shell/neovim-full.nix
    { inherit custom; }
  ];
}
