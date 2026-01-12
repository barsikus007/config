{
  lib,
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
  programs.vscode = with pkgs; {
    enable = false;
    package = vscodium;
    profiles.default = {
      enableUpdateCheck = false;
      keybindings = builtins.fromJSON (
        builtins.readFile (
          runCommand "clean-json" { } ''
            ${lib.getExe hjson-go} -j  ${../../.config/Code/User/keybindings.json} > $out
          ''
        )
      );
      userSettings = builtins.fromJSON (
        builtins.readFile (
          runCommand "clean-json" { } ''
            ${lib.getExe hjson-go} -j ${../../.config/Code/User/settings.json} > $out
          ''
        )
      );
      extensions = with vscode-extensions; [
        yzhang.markdown-all-in-one
        jnoortheen.nix-ide
      ];
    };
  };
  home.packages = with pkgs; [
    vscode
    #! https://github.com/NixOS/nixpkgs/blob/c23193b943c6c689d70ee98ce3128239ed9e32d1/pkgs/applications/editors/vscode/generic.nix#L82
    # vscode-fhs
  ];
}
