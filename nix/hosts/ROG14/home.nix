{ lib, ... }:
{
  imports = [
    ../../shared

    ../../home
    ../../home/shell
    ../../home/editors.nix

    ../../home/hardware/anime.nix

    ../../home/stylix.nix
    ../../home/shell/404.nix
    ../../home/shell/bat.nix
    ../../home/ai.nix

    ../../home/gui
    ../../home/gui/sound.nix
    ../../home/gui/autostart.nix
    ../../home/gui/syncthing.nix
    ../../home/gui/quickshare.nix
    ../../home/gui/terminal.nix
    ../../home/gui/plasma.nix
    ../../home/gui/rofi.nix
    ../../home/gui/mpv.nix
    ../../home/gui/vscode.nix
    ../../home/gui/browser.nix
    ../../home/gui/social.nix
    ../../home/gui/office.nix
    ../../home/gui/bcompare.nix
    ../../home/gui/vm.nix

    ../../home/gui/games
    ../../home/gui/games/minecraft.nix
    {
      programs.nvf.settings.vim.lsp.enable = lib.mkForce true;
    }
    {
      home = {
        #? https://nix-community.github.io/home-manager/release-notes.xhtml
        stateVersion = "26.05";
        sessionVariables = {
          # fuck the firefox
          LC_TIME = "en_GB.UTF-8";
        };
      };
    }
  ];
}
