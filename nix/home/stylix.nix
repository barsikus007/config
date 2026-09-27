{ config, ... }:
{
  imports = [ ./gui/browser/firefox-stylix.nix ];

  #? to apply stylix setted cursors
  home.pointerCursor.enable = true;

  stylix = {
    enable = true;
    # autoEnable = false;
    targets = {
      #? stylix uses kvantum for theming, hardcoding svg (which is used for element shapes)
      #? I don't like these shapes so I decided to just rollback to breeze
      #? and also, no support for kde platform
      qt.enable = false;
      #? stop creating ~/.themes and breaking breeze linking
      gtk.flatpakSupport.enable = false;

      #? conflicts with custom theme
      bat.enable = false;
      #? isn't switching with script
      fzf.enable = false;
      #? conflicts with current setup
      mpv.enable = false;
      #? conflicts with current setup
      starship.enable = false;
      #? conflicts with custom theme
      vscode.enable = false;
      #? theme is unreadable
      gdu.enable = false;
      #! theme could be unreadable, but now it is ok
      # nixcord.enable = false;

      firefox.profileNames = [ "default" ];
      firefox.fonts.enable = false;
    };
  };

  #! this thing needs all extensions settings to be declared
  # stylix.targets.firefox.colorTheme.enable = true;
  # programs.firefox.profiles.default.extensions.force = true;

  programs.neovide.settings.font = {
    normal = [ config.stylix.fonts.monospace.name ];
    size = config.stylix.fonts.sizes.terminal;
  };
}
