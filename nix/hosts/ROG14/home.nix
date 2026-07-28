{ custom, ... }:
{
  imports = [
    ../../shared/options.nix

    ../../home
    ../../home/shell

    ../../home/ai.nix

    ../../home/xdg/desktop.nix
    ../../home/xdg/autostart.nix
    ../../home/xdg/base-dirs.nix

    ../../home/gui/syncthing.nix
    ../../home/gui/keepassxc.nix
    ../../home/gui/quickshare.nix
    ../../home/gui/terminal.nix
    ../../home/gui/neovide.nix
    ../../home/gui/mpv.nix
    ../../home/gui/vscode.nix
    ../../home/gui/browser
    ../../home/gui/social
    ../../home/gui/office.nix
    ../../home/gui/bcompare.nix
    ../../home/gui/vm.nix

    ../../home/gui/games
    ../../home/gui/games/minecraft.nix
    {
      inherit custom;

      programs.nvf.settings.vim.lsp.enable = true;
    }
  ];
}
