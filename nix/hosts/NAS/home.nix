{ custom, ... }:
{
  imports = [
    ../../shared

    ../../home
    ../../home/shell
    ../../home/editors.nix
    {
      programs.nvf.settings.vim.lsp.enable = true;
    }
    {
      inherit custom;
      home = {
        #? https://nix-community.github.io/home-manager/release-notes.xhtml
        stateVersion = "26.05";
      };
    }
  ];
}
