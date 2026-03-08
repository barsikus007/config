{ config, username, ... }:
{
  imports = [ ./git.nix ];
  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    inherit username;
    homeDirectory = "/home/${username}";

    #? https://wiki.nixos.org/wiki/Environment_variables
    sessionVariables = {
      # Not officially in the specification
      XDG_BIN_HOME = "$HOME/.local/bin";
    };
    sessionPath = [
      "${config.home.sessionVariables.XDG_BIN_HOME}"
    ];
    preferXdgDirectories = true;
  };
  xdg.enable = true;
}
