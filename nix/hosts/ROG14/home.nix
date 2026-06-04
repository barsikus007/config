{ custom, ... }:
{
  imports = [
    ../../shared/options.nix

    ../../home
    ../../home/shell
    ../../home/editors.nix

    ../../home/ai.nix

    ../../home/gui
    ../../home/gui/sound.nix
    ../../home/gui/autostart.nix
    ../../home/gui/syncthing.nix
    ../../home/gui/quickshare.nix
    ../../home/gui/terminal.nix
    ../../home/gui/neovide.nix
    ../../home/gui/rofi.nix
    ../../home/gui/mpv.nix
    ../../home/gui/vscode.nix
    ../../home/gui/browser
    ../../home/gui/social.nix
    ../../home/gui/office.nix
    ../../home/gui/bcompare.nix
    ../../home/gui/vm.nix

    ../../home/gui/games
    ../../home/gui/games/minecraft.nix
    {
      programs.nvf.settings.vim.lsp.enable = true;
    }
    {
      inherit custom;

      # TODO: fuck the firefox ?
      home.sessionVariables.LC_TIME = "en_GB.UTF-8";
    }
  ];
}
