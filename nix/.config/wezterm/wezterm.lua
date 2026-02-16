local wezterm = require 'wezterm'
local act = wezterm.action

return {
    -- font = wezterm.font("Cascadia Code NF"),
    -- font_size = 12.0,
    -- TODO
    warn_about_missing_glyphs = false,

    -- color_scheme = "Catppuccin Mocha",

    --! x have issues with this
    use_resize_increments = true,
    initial_cols = 120,
    initial_rows = 30,
    enable_scroll_bar = true,

    --! wayland have titlebar issues
    -- enable_wayland = false,
    -- window_decorations = "INTEGRATED_BUTTONS|RESIZE",
    -- this draws default header on wayland
    -- window_decorations = "INTEGRATED_BUTTONS|NONE",
    -- window_decorations = "NONE",
    hide_tab_bar_if_only_one_tab = true,
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    },

    --? https://wezterm.org/config/default-keys.html
    keys = {
        --? https://wezterm.org/config/lua/keyassignment/CloseCurrentTab.html
        { key = 'q',   mods = 'CTRL',       action = act.CloseCurrentTab { confirm = false } },
        --! it slightly differs from usual MRU
        --? https://github.com/wezterm/wezterm/issues/4518
        { key = "Tab", mods = 'CTRL',       action = "ActivateLastTab" },
        { key = 'Tab', mods = 'CTRL',       action = act.ActivateTabRelative(1) },
        { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },

        --! intersects with yazi
        -- { key = "F1", action = "ActivateCommandPalette" },
        --! should be handled by system
        -- { key = "F11", action = "ToggleFullScreen" },
        {
            key = 'c',
            mods = 'CTRL',
            action = wezterm.action_callback(function(window, pane)
                local selection_text = window:get_selection_text_for_pane(pane)
                local is_selection_active = string.len(selection_text) ~= 0
                if is_selection_active then
                    window:perform_action(act.CopyTo('ClipboardAndPrimarySelection'), pane)
                    -- https://wezterm.org/config/lua/keyassignment/ClearSelection.html
                    window:perform_action(act.ClearSelection, pane)
                else
                    window:perform_action(act.SendKey { key = 'c', mods = 'CTRL' }, pane)
                end
            end),
        },
        {
            key = 'v',
            mods = 'CTRL',
            action = act.PasteFrom('Clipboard')
        },
        {
            key = 'v',
            mods = 'CTRL|SHIFT',
            --! fucked up with noctalia-shell cliphist paste
            -- action = act.SendKey { key = 'v', mods = 'CTRL' }
            action = act.PasteFrom('Clipboard')
        },
    },
    key_tables = {
        search_mode = {
            -- default
            { key = 'Enter',     mods = 'NONE', action = act.CopyMode 'PriorMatch' },
            { key = 'Escape',    mods = 'NONE', action = act.CopyMode 'Close' },
            { key = 'n',         mods = 'CTRL', action = act.CopyMode 'NextMatch' },
            { key = 'p',         mods = 'CTRL', action = act.CopyMode 'PriorMatch' },
            { key = 'r',         mods = 'CTRL', action = act.CopyMode 'CycleMatchType' },
            { key = 'u',         mods = 'CTRL', action = act.CopyMode 'ClearPattern' },
            { key = 'PageUp',    mods = 'NONE', action = act.CopyMode 'PriorMatchPage' },
            { key = 'PageDown',  mods = 'NONE', action = act.CopyMode 'NextMatchPage' },
            { key = 'UpArrow',   mods = 'NONE', action = act.CopyMode 'PriorMatch' },
            { key = 'DownArrow', mods = 'NONE', action = act.CopyMode 'NextMatch' },
            {
                key = 'F3',
                mods = 'NONE',
                action = act.CopyMode 'NextMatchPage',
            },
            {
                key = 'F3',
                mods = 'SHIFT',
                action = act.CopyMode 'PriorMatchPage',
            },
        },
    },
    mouse_bindings = {
        -- Right click behaves like windows
        {
            event = { Down = { streak = 1, button = 'Right' } },
            mods = 'NONE',
            action = wezterm.action_callback(function(window, pane)
                local selection_text = window:get_selection_text_for_pane(pane)
                local is_selection_active = string.len(selection_text) ~= 0
                if is_selection_active then
                    window:perform_action(act.CopyTo('ClipboardAndPrimarySelection'), pane)
                    -- https://wezterm.org/config/lua/keyassignment/ClearSelection.html
                    window:perform_action(act.ClearSelection, pane)
                else
                    window:perform_action(act.PasteFrom('Clipboard'), pane)
                end
            end),
        },
        -- https://wezterm.org/recipes/hyperlinks.html#optional-configuration
        {
            event = { Up = { streak = 1, button = 'Left' } },
            mods = 'CTRL',
            action = act.OpenLinkAtMouseCursor,
        },
        -- Disable the 'Down' event of CTRL-Click to avoid weird program behaviors
        {
            event = { Down = { streak = 1, button = 'Left' } },
            mods = 'CTRL',
            action = act.Nop,
        },
        -- https://wezterm.org/config/mouse.html#configuring-mouse-assignments
        {
            event = { Up = { streak = 1, button = 'Left' } },
            mods = 'NONE',
            action = act.CompleteSelection 'ClipboardAndPrimarySelection',
        },
        -- Scrolling up while holding CTRL increases the font size
        {
            event = { Down = { streak = 1, button = { WheelUp = 1 } } },
            mods = 'CTRL',
            action = act.IncreaseFontSize,
        },

        -- Scrolling down while holding CTRL decreases the font size
        {
            event = { Down = { streak = 1, button = { WheelDown = 1 } } },
            mods = 'CTRL',
            action = act.DecreaseFontSize,
        },
    }
}
