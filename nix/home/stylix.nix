{ config, ... }:
{
  stylix = {
    enable = true;
    # autoEnable = false;
    targets = {
      # TODO: unstable: https://github.com/nix-community/stylix/issues/869: user profile: stylix: qt: `config.stylix.targets.qt.platform` other than 'qtct' are currently unsupported: kde. Support may be added in the future.
      # TODO: unstable: https://github.com/NixOS/nixpkgs/issues/359129
      # qt.platform = "qtct";

      mpv.enable = false;
      vscode.enable = false;
      nixcord.enable = false;

      #? due to font troubles
      firefox.enable = false;
      # firefox.profileNames = [ "default" ];

      #? shell
      bat.enable = false;
      fzf.enable = false;
    };
  };

  programs.neovide.settings.font = {
    normal = [ config.stylix.fonts.monospace.name ];
    size = config.stylix.fonts.sizes.terminal;
  };
}
