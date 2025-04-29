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

      window-step-resize = true;
      #! scrollbar https://github.com/ghostty-org/ghostty/issues/111
      #! search https://github.com/ghostty-org/ghostty/issues/189
      #? copy-on-right-click https://github.com/ghostty-org/ghostty/issues/4404
      #? clear selection
      #? mru ctrl+tab
      #? tabs works like shit
      #? tabs should be on header
      #? can't bind window size to char symbol

      keybind = [
        "performable:ctrl+c=copy_to_clipboard"
        "performable:ctrl+v=paste_from_clipboard"
        "ctrl+shift+v=text:\\x16"
        "f11=toggle_fullscreen"
        "f12=jump_to_prompt:1"
      ];
    };
    # installVimSyntax = true;
    # themes = { catppuccin-mocha = «thunk»; };
  };
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {
        font = wezterm.font("Cascadia Code NF"),
        -- font_size = 16.0,
        color_scheme = "Catppuccin Mocha",
        hide_tab_bar_if_only_one_tab = true,
        use_resize_increments = false,
        enable_scroll_bar = true,
        keys = {
          -- {key="n", mods="SHIFT|CTRL", action="ToggleFullScreen"},
          {key="F11", action="ToggleFullScreen"},
          {
            key = 'c',
            mods = 'CTRL',
            action = wezterm.action_callback(function(window, pane)
              selection_text = window:get_selection_text_for_pane(pane)
              is_selection_active = string.len(selection_text) ~= 0
              if is_selection_active then
                window:perform_action(wezterm.action.CopyTo('ClipboardAndPrimarySelection'), pane)
              else
                window:perform_action(wezterm.action.SendKey{ key='c', mods='CTRL' }, pane)
              end
            end),
          },
        }
      }
    '';
  };
}
