{
  config,
  username,
  flakePath,
  pkgs,
  ...
}:
{
  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    inherit username;
    homeDirectory = "/home/${config.home.username}";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "25.05";

    # packages = import ./shared/lists/extra.nix { inherit pkgs; };
    # packages = import ./shared/lists { inherit pkgs; };

    #? https://wiki.nixos.org/wiki/Environment_variables
    sessionVariables = {
      # Not officially in the specification
      XDG_BIN_HOME = "$HOME/.local/bin";
    };
    sessionPath = [
      "${config.home.sessionVariables.XDG_BIN_HOME}"
    ];
  };

  xdg.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.nh = {
    enable = true;
    flake = flakePath;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    # TODO
    # aliases = {
    #   ci = "commit";
    #   co = "checkout";
    #   s = "status";
    # };
    settings = {
      user.name = "barsikus007";
      user.email = "barsikus07@gmail.com";
      core.editor = "code --wait";
      core.autocrlf = "input";
      core.ignoreCase = "false";

      init.defaultBranch = "master";

      push.default = "current";

      pull.rebase = "true";

      merge.autoStash = "true";

      rebase.autoStash = "true";

      gpg.format = "ssh";
    };
    # TODO: secrets: https://wiki.nixos.org/wiki/Git#Using_your_public_SSH_key_as_a_signing_key
    signing.key = "~/.ssh/id_ed25519.pub";
    signing.signByDefault = true;
  };
}
