{ inputs, ... }:
{
  imports = [
    inputs.stylix.homeManagerModules.stylix
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
    };
  };
}
