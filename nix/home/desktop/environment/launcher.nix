{ config, flakePath, ... }:
{
  programs.vicinae = {
    enable = true;
    systemd.enable = true;
    # extensions = [];
    settings = {
      close_on_focus_loss = true;
      #? controlled by niri
      launcher_window.client_side_decorations.enabled = true;

      launcher_window.layer_shell.layer = "overlay";
    };
  };
  xdg.configFile."vicinae/settings.json".target = "vicinae/settings-static.json";
  xdg.configFile."vicinae/settings.json-real" = {
    target = "vicinae/settings.json";
    source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/vicinae/settings.json";
  };
}
