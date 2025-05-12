{ lib, inputs, config, ... }:
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

  # TODO: unstable 25.05
  programs.nvf.settings.vim = lib.mkForce {
    statusline.lualine.theme = "base16";
    theme = {
      enable = true;
      name = "base16";
      base16-colors = {
        inherit (config.lib.stylix.colors)
          base00
          base01
          base02
          base03
          base04
          base05
          base06
          base07
          base08
          base09
          base0A
          base0B
          base0C
          base0D
          base0E
          base0F
          ;
      };
      transparent = false;
    };
  };
}
