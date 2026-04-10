{ config, flakePath, ... }:
#! 21Mb
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      alias = {
        ci = "commit";
        co = "checkout";
        s = "status";
      };
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
    # TODO: only on main machine
    # TODO: secrets: https://wiki.nixos.org/wiki/Git#Using_your_public_SSH_key_as_a_signing_key
    signing.key = "~/.ssh/id_ed25519.pub";
    signing.signByDefault = true;
  };
  xdg.configFile."git/ignore".source =
    config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/git/ignore";
  programs.delta.enable = true;
  programs.delta.enableGitIntegration = true;
}
