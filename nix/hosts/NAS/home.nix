{ custom, ... }:
{
  imports = [
    ../../shared/options.nix

    ../../home
    ../../home/shell
    ../../home/editors.nix
    {
      inherit custom;

      programs.nvf.settings.vim.lsp.enable = true;
    }
  ];
}
