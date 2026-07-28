{ custom, ... }:
{
  imports = [
    ../../shared/options.nix

    ../../home
    ../../home/shell
    {
      inherit custom;

      programs.nvf.settings.vim.lsp.enable = true;
    }
  ];
}
