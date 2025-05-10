{
  pkgs,
  config,
  flakePath,
  ...
}:
{
  xdg.configFile = {
    "Code/User/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/Code/User/settings.json";
    "Code/User/keybindings.json".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/Code/User/keybindings.json";
  };
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscodium;
    # enableUpdateCheck = false;
    # keybindings = builtins.fromJSON (builtins.replaceStrings ["//.*\n"] [""] (builtins.readFile ../../.config/Code/User/keybindings.json));
    extensions = with pkgs.vscode-extensions; [
      yzhang.markdown-all-in-one
      jnoortheen.nix-ide
    ];
  };
}
