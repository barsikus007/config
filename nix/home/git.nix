{
  lib,
  config,
  flakePath,
  ...
}:
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
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
    };
    signing.key = "key::${
      lib.strings.removeSuffix "\n" (
        builtins.readFile (
          builtins.fetchurl {
            url = "https://github.com/barsikus007.keys";
            sha256 = "sha256-Tnf/WxeYOikI9i5l4e0ABDk33I5z04BJFApJpUplNi0=";
          }
        )
      )
    }";
    signing.signByDefault = true;
  };
  xdg.configFile."git/ignore".source =
    config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/git/ignore";
  programs.delta.enable = true;
  programs.delta.enableGitIntegration = true;
}
