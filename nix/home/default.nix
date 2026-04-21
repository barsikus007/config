{ username, ... }:
{
  imports = [ ./git.nix ];
  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    inherit username;
    homeDirectory = "/home/${username}";

    preferXdgDirectories = true;
  };
  xdg.enable = true;
}
