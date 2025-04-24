{ ... }:
{
  # TODO fix rus keys https://github.com/ghostty-org/ghostty/issues/3513 check on fedora
  # TODO ghostty +show-config
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    settings = {
      theme = "catppuccin-mocha";
      # theme = "shades-of-purple";
      # TODO link to font pkg
      font-family = "Cascadia Code NF";
      # window-decoration = "none";
      window-decoration = "client";

      keybind = [
        "performable:ctrl+c=copy_to_clipboard"
        # TODO clear selection
        "performable:ctrl+v=paste_from_clipboard"
        "ctrl+shift+v=text:\\x16"
        "f11=toggle_fullscreen"
        "f12=jump_to_prompt:1"
        # TODO sad https://github.com/ghostty-org/ghostty/issues/111
        # sad2 https://github.com/ghostty-org/ghostty/issues/4404
        # sad3 https://github.com/ghostty-org/ghostty/issues/1890
      ];
    };
    # installVimSyntax = true;
    # themes = { catppuccin-mocha = «thunk»; };
  };
}
