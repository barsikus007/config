{ config, ... }:
{
  stylix = {
    enable = true;
    # autoEnable = false;
    targets = {
      # TODO: unstable: https://github.com/nix-community/stylix/issues/869: user profile: stylix: qt: `config.stylix.targets.qt.platform` other than 'qtct' are currently unsupported: kde. Support may be added in the future.
      # TODO: unstable: https://github.com/NixOS/nixpkgs/issues/359129
      #! values others from "kde" breaks plasma
      # qt.platform = "kde";

      #? conflicts with custom theme
      bat.enable = false;
      #? isn't switching with script
      fzf.enable = false;
      #? conflicts with current setup
      mpv.enable = false;
      #? conflicts with custom theme
      vscode.enable = false;
      #? due to font troubles; theme isn't working
      firefox.enable = false;
      #? theme is unreadable
      gdu.enable = false;
      nixcord.enable = false;
    };
  };

  programs.neovide.settings.font = {
    normal = [ config.stylix.fonts.monospace.name ];
    size = config.stylix.fonts.sizes.terminal;
  };
}
