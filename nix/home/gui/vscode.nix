{
  lib,
  pkgs,
  config,
  flakePath,
  ...
}:
{
  custom.persist.home.directories = [
    ".config/Code"
    ".vscode"
    ".vscode-shared" # ? recent and trust folders
  ];

  xdg.configFile = {
    "Code/User/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/Code/User/settings.json";
    "Code/User/keybindings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/Code/User/keybindings.json";
  };
  programs.git.settings.core.editor = "code --wait";
  programs.vscodium = {
    # enable = true;
    profiles.default = {
      enableUpdateCheck = false;
      keybindings = builtins.fromJSON (
        builtins.readFile (
          pkgs.runCommand "clean-json" { } ''
            ${lib.getExe pkgs.hjson-go} -j  ${../../.config/Code/User/keybindings.json} > $out
          ''
        )
      );
      userSettings = builtins.fromJSON (
        builtins.readFile (
          pkgs.runCommand "clean-json" { } ''
            ${lib.getExe pkgs.hjson-go} -j ${../../.config/Code/User/settings.json} > $out
          ''
        )
      );
      extensions = with pkgs.vscode-extensions; [
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
  programs.zed-editor = {
    # enable = true;
    extensions = [
      "comment"
      "nix"
    ];
    userSettings = {
      tabs = {
        file_icons = true;
      };
      telemetry = {
        metrics = false;
      };
    };
  };
}
