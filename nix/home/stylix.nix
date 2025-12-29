{ config, ... }:
{
  stylix = {
    enable = true;
    # autoEnable = false;
    targets = {
      # TODO: unstable: https://github.com/nix-community/stylix/issues/869: user profile: stylix: qt: `config.stylix.targets.qt.platform` other than 'qtct' are currently unsupported: kde. Support may be added in the future.
      # TODO: unstable: https://github.com/NixOS/nixpkgs/issues/359129
      # qt.platform = "qtct";

      #? conflicts with custom theme
      bat.enable = false;
      # TODO: check why this is disabled (TTYs?)
      # fzf.enable = false;
      #? conflicts with current setup
      mpv.enable = false;
      #? conflicts with custom theme
      vscode.enable = false;
      #? due to font troubles; theme isn't working
      firefox.enable = false;
      #? theme is unreadable
      nixcord.enable = false;
    };
  };

  programs.neovide.settings.font = {
    normal = [ config.stylix.fonts.monospace.name ];
    size = config.stylix.fonts.sizes.terminal;
  };
  services.darkman = {
    enable = true;
    darkModeScripts = {
      switch-to-dark = "sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch";
    };
    lightModeScripts = {
      switch-to-light = "sudo /nix/var/nix/profiles/system/specialisation/light/bin/switch-to-configuration switch";
    };
    settings = {
      lat = 42;
      lng = 40;
      # usegeoclue = true;
    };
  };
}
