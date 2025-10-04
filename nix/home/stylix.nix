{ inputs, config, ... }:
{
  imports = [
    inputs.stylix.homeModules.stylix
    ../shared/stylix.nix
  ];
  stylix = {
    enable = true;
    # autoEnable = false;
    targets = {
      # kde.enable = false;
      # gtk.enable = false;
      bat.enable = false;
      vscode.enable = false;
      nixcord.enable = false;

      firefox.profileNames = [ "default" ];
      mpv.enable = false;
    };
  };

  programs.neovide.settings.font = {
    normal = [ config.stylix.fonts.monospace.name ];
    size = config.stylix.fonts.sizes.terminal;
  };
}
