{
  pkgs,
  config,
  flakePath,
  ...
}:
{
  xdg.configFile = {
    "Code/User/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/Code/User/settings.json";
    "Code/User/keybindings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/Code/User/keybindings.json";
  };
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscodium;
    enableUpdateCheck = false;
    keybindings = builtins.fromJSON (
      builtins.readFile (
        pkgs.runCommand "clean-json" { } ''
          ${pkgs.hjson-go}/bin/hjson-cli -j  ${../../.config/Code/User/keybindings.json} > $out
        ''
      )
    );
    userSettings = builtins.fromJSON (
      builtins.readFile (
        pkgs.runCommand "clean-json" { } ''
          ${pkgs.hjson-go}/bin/hjson-cli -j ${../../.config/Code/User/settings.json} > $out
        ''
      )
    );
    extensions = with pkgs.vscode-extensions; [
      yzhang.markdown-all-in-one
      jnoortheen.nix-ide
    ];
  };
}
