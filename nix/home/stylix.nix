{
  lib,
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.stylix.homeModules.stylix
    ../shared/stylix.nix
  ];
  stylix = {
    enable = true;
    # TODO disable plasma reload every home config switch!
    # autoEnable = false;
    targets = {
      # qt.enable = false;
      kde.enable = false;
      bat.enable = false;
      # wezterm.enable = true;
      vscode.enable = false;

      firefox.profileNames = [ "default" ];
      starship.enable = false;
      mpv.enable = false;
    };
  };


  programs.neovide.settings.font = {
    normal = [ config.stylix.fonts.monospace.name ];
    size = config.stylix.fonts.sizes.terminal;
  };
}
