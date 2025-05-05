local wezterm = require 'wezterm'
local act = wezterm.action

return {
    -- font = wezterm.font("Cascadia Code NF"),
    -- TODO
    warn_about_missing_glyphs=false,
    -- font_size = 12.0,

    -- color_scheme = "Catppuccin Mocha",

    --! x have issues with this
    use_resize_increments = true,
    initial_cols = 120,
    initial_rows = 30,
    enable_scroll_bar = true,

    --! wayland have fullscreen (fixed) and titlebar issues at 2025.01 version
    enable_wayland = false,
    window_decorations = "INTEGRATED_BUTTONS|RESIZE",
    -- this draws default header on wayland
    -- window_decorations = "INTEGRATED_BUTTONS|NONE",
    hide_tab_bar_if_only_one_tab = true,
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    },

    keys = {
        { key = "F11", action = "ToggleFullScreen" },
        {
            key = 'c',
            mods = 'CTRL',
            action = wezterm.action_callback(function(window, pane)
                local selection_text = window:get_selection_text_for_pane(pane)
                local is_selection_active = string.len(selection_text) ~= 0
                if is_selection_active then
                    window:perform_action(wezterm.action.CopyTo('ClipboardAndPrimarySelection'), pane)
                else
                    window:perform_action(wezterm.action.SendKey { key = 'c', mods = 'CTRL' }, pane)
                end
            end),
        },
        {
            key = 'v',
            mods = 'CTRL',
            action = wezterm.action.PasteFrom('Clipboard')
        },
    },
    -- key_tables = {
    --     search_mode = {
    --         { key = 'Enter',  mods = 'NONE', action = act.CopyMode 'PriorMatch' },
    --         { key = 'Escape', mods = 'NONE', action = act.CopyMode 'Close' },
    --         { key = 'n',      mods = 'CTRL', action = act.CopyMode 'NextMatch' },
    --         { key = 'p',      mods = 'CTRL', action = act.CopyMode 'PriorMatch' },
    --         { key = 'r',      mods = 'CTRL', action = act.CopyMode 'CycleMatchType' },
    --         { key = 'u',      mods = 'CTRL', action = act.CopyMode 'ClearPattern' },
    --         {
    --             key = 'F3',
    --             mods = 'SHIFT',
    --             action = act.CopyMode 'PriorMatchPage',
    --         },
    --         {
    --             key = 'F3',
    --             mods = 'NONE',
    --             action = act.CopyMode 'NextMatchPage',
    --         },
    --         { key = 'UpArrow', mods = 'NONE', action = act.CopyMode 'PriorMatch' },
    --         { key = 'DownArrow', mods = 'NONE', action = act.CopyMode 'NextMatch' },
    --     },
    -- },
}
