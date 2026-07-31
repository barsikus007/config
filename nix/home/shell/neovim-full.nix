{ pkgs, ... }:
{
  imports = [ ./neovim.nix ];

  programs.nvf.settings.vim.lsp.enable = true;

  home.packages = with pkgs; [
    lua-language-server
    stylua

    pyright
    ruff
  ];
  # TODO: programs.ruff to separate it from vscode settings; but it wouldn;t work for servers?
}
