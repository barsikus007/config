{
  lib,
  pkgs,
  config,
  flakePath,
  ...
}:
let
  editor = "code --wait";
in
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
  programs.git.settings.core = { inherit editor; };
  home.sessionVariables = {
    SOPS_EDITOR = editor;
  };
  programs.vscodium = {
    enable = true;
    package = lib.lowPrio pkgs.vscodium;
    profiles.default = {
      enableUpdateCheck = false;
      keybindings = builtins.fromJSON (
        builtins.readFile (
          pkgs.runCommand "clean-json" { } ''
            ${lib.getExe pkgs.hjson-go} -j  ${../../.config/Code/User/keybindings.json} > $out
          ''
        )
      );
      userSettings =
        builtins.fromJSON (
          builtins.readFile (
            pkgs.runCommand "clean-json" { } ''
              ${lib.getExe pkgs.hjson-go} -j ${../../.config/Code/User/settings.json} > $out
            ''
          )
        )
        // {
          "security.workspace.trust.enabled" = false;
          "workbench.editor.showTabs" = "none";
          "workbench.startupEditor" = "none";
          "window.restoreWindows" = "none";
          "window.openFilesInNewWindow" = "off";
          "window.openFoldersInNewWindow" = "off";
          "window.openWithoutArgumentsInNewWindow" = "off";
          "window.menuBarVisibility" = "compact";
          "workbench.editor.editorActionsLocation" = "titleBar";
        };
      extensions =
        (import ../../.config/Code/User/extensions.nix { inherit pkgs; }).forTags [
          "essential"
          "docs"
          "nix"
        ]
        ++ [
          (pkgs.vscode-utils.extensionFromVscodeMarketplace {
            name = "shades-of-purple";
            publisher = "ahmadawais";
            version = "7.3.6";
            hash = "sha256-22ZywGew1Qh4YPi51JWTNQLKuz/nzx/iprUK96DQfYU=";
          })
        ];
    };
  };
  home.packages = with pkgs; [
    vscode
    #! https://github.com/NixOS/nixpkgs/blob/c23193b943c6c689d70ee98ce3128239ed9e32d1/pkgs/applications/editors/vscode/generic.nix#L82
    # vscode-fhs
  ];
}
