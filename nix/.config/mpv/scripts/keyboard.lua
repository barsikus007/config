--! vibecoded shitscript
-- with its bound action, resolving both latin and cyrillic (ЙЦУКЕН) mappings
-- with its bound action, resolving both latin and cyrillic (ЙЦУКЕН) mappings
-- toggle: script-binding keyboard/toggle  (bound to F1 in input.conf)
-- while open: 1=base 2=shift 3=alt 4=ctrl layers, Esc/F1 close

local mp = require "mp"
local assdraw = require "mp.assdraw"

--! ЙЦУКЕН: physical latin key -> cyrillic char sitting on the same key
local CYR = {
    ["`"] = "ё",
    q = "й", w = "ц", e = "у", r = "к", t = "е", y = "н",
    u = "г", i = "ш", o = "щ", p = "з", ["["] = "х", ["]"] = "ъ",
    a = "ф", s = "ы", d = "в", f = "а", g = "п", h = "р",
    j = "о", k = "л", l = "д", [";"] = "ж", ["'"] = "э",
    z = "я", x = "ч", c = "с", v = "м", b = "и", n = "т",
    m = "ь", [","] = "б", ["."] = "ю", ["/"] = ".",
}

--! shifted symbol produced by each key (US layout) for the shift layer
local SHIFT_SYM = {
    ["`"] = "~", ["1"] = "!", ["2"] = "@", ["3"] = "#", ["4"] = "$",
    ["5"] = "%", ["6"] = "^", ["7"] = "&", ["8"] = "*", ["9"] = "(",
    ["0"] = ")", ["-"] = "_", ["="] = "+", ["["] = "{", ["]"] = "}",
    ["\\"] = "|", [";"] = ":", ["'"] = "\"", [","] = "<", ["."] = ">",
    ["/"] = "?",
}

--! rows of the keyboard; entries are {name, label, w} or {spacer=units}
--! name is the base (unshifted, latin) mpv key token; w defaults to 1
local ROWS = {
    { y = 0.0, keys = {
        { "ESC", "Esc" }, { spacer = 1 },
        { "F1", "F1" }, { "F2", "F2" }, { "F3", "F3" }, { "F4", "F4" }, { spacer = 0.5 },
        { "F5", "F5" }, { "F6", "F6" }, { "F7", "F7" }, { "F8", "F8" }, { spacer = 0.5 },
        { "F9", "F9" }, { "F10", "F10" }, { "F11", "F11" }, { "F12", "F12" },
    } },
    { y = 1.15, keys = {
        { "`", "`" }, { "1", "1" }, { "2", "2" }, { "3", "3" }, { "4", "4" },
        { "5", "5" }, { "6", "6" }, { "7", "7" }, { "8", "8" }, { "9", "9" },
        { "0", "0" }, { "-", "-" }, { "=", "=" }, { "BS", "⌫", w = 2 },
    } },
    { y = 2.15, keys = {
        { "TAB", "Tab", w = 1.5 },
        { "q", "Q" }, { "w", "W" }, { "e", "E" }, { "r", "R" }, { "t", "T" },
        { "y", "Y" }, { "u", "U" }, { "i", "I" }, { "o", "O" }, { "p", "P" },
        { "[", "[" }, { "]", "]" }, { "\\", "\\", w = 1.5 },
    } },
    { y = 3.15, keys = {
        { "CAPS", "Caps", w = 1.75 },
        { "a", "A" }, { "s", "S" }, { "d", "D" }, { "f", "F" }, { "g", "G" },
        { "h", "H" }, { "j", "J" }, { "k", "K" }, { "l", "L" }, { ";", ";" },
        { "'", "'" }, { "ENTER", "Enter", w = 2.25 },
    } },
    { y = 4.15, keys = {
        { "SHIFT", "Shift", w = 2.25 },
        { "z", "Z" }, { "x", "X" }, { "c", "C" }, { "v", "V" }, { "b", "B" },
        { "n", "N" }, { "m", "M" }, { ",", "," }, { ".", "." }, { "/", "/" },
        { "SHIFT", "Shift", w = 2.75 },
    } },
    { y = 5.15, keys = {
        { "CTRL", "Ctrl", w = 1.25 }, { "META", "Win", w = 1.25 }, { "ALT", "Alt", w = 1.25 },
        { "SPACE", "Space", w = 6.25 },
        { "ALT", "Alt", w = 1.25 }, { "META", "Win", w = 1.25 }, { "MENU", "Menu", w = 1.25 },
        { "CTRL", "Ctrl", w = 1.25 },
    } },
}

local UNITS_W = 15    -- total width in key units
local UNITS_H = 6.15  -- bottom of the last row in key units

--! colors are ASS &HBBGGRR (BGR)
local COL = {
    bg       = "000000",
    key      = "1c1c22",
    key_bord = "3a3a42",
    bound    = "24242e",
    accent   = "ffb300", -- azure border on bound keys (#00b3ff)
    label    = "e6e6e6",
    dim      = "6a6a6a",
    action   = "d0d0d0",
    title    = "ffffff",
}

local visible = false
local overlay = nil
local layer = "base"
local forced = {}

--! normalize a binding key: lowercase modifier tokens, keep the final key
local function normalize(key)
    local parts = {}
    for tok in string.gmatch(key, "[^+]+") do
        parts[#parts + 1] = tok
    end
    for i = 1, #parts - 1 do
        local m = parts[i]:lower()
        if m == "ctrl" or m == "alt" or m == "shift" or m == "meta" then
            parts[i] = m
        end
    end
    return table.concat(parts, "+")
end

--! build lookup of active bindings, preferring entries that carry a comment
local function build_map()
    local map = {}
    local binds = mp.get_property_native("input-bindings") or {}
    for _, b in ipairs(binds) do
        if b.key and b.key ~= "" then
            local n = normalize(b.key)
            local cur = map[n]
            local has_c = b.comment and b.comment ~= ""
            local cur_c = cur and cur.comment and cur.comment ~= ""
            if not cur or (has_c and not cur_c) then
                map[n] = { cmd = b.cmd, comment = b.comment }
            end
        end
    end
    return map
end

--! candidate binding-key strings for a physical key on the given layer
local function candidates(name, cyr, lay)
    local c = {}
    local is_letter = name:match("^%a$")
    if lay == "base" then
        c[#c + 1] = name
        if cyr then c[#c + 1] = cyr end
    elseif lay == "shift" then
        if is_letter then c[#c + 1] = name:upper() end
        if cyr and cyr:match("%a") then c[#c + 1] = cyr:upper() end
        c[#c + 1] = "shift+" .. name
        if cyr then c[#c + 1] = "shift+" .. cyr end
        local s = SHIFT_SYM[name]
        if s then c[#c + 1] = s; c[#c + 1] = "shift+" .. s end
    elseif lay == "alt" then
        c[#c + 1] = "alt+" .. name
        if is_letter then c[#c + 1] = "alt+" .. name:upper() end
        if cyr then c[#c + 1] = "alt+" .. cyr end
    elseif lay == "ctrl" then
        c[#c + 1] = "ctrl+" .. name
        if cyr then c[#c + 1] = "ctrl+" .. cyr end
    end
    return c
end

--! shorten a command/comment into a readable action label
local function clean(entry)
    local t = entry.comment
    if not t or t == "" then t = entry.cmd or "" end
    t = t:gsub("^no%-osd%s+", "")
    t = t:gsub("script%-message%-to%s+", "→")
    t = t:gsub("script%-binding%s+", "")
    t = t:gsub("cycle%-values", "cycle")
    t = t:gsub("%s*;%s*show%-text.*$", "")
    t = t:gsub("^%s+", ""):gsub("%s+$", "")
    return t
end

--! greedy word-wrap into at most `lines` rows of ~`w` chars, then ellipsize
local function wrap(text, w, lines)
    local out, cur = {}, ""
    for word in text:gmatch("%S+") do
        if cur == "" then
            cur = word
        elseif #cur + 1 + #word <= w then
            cur = cur .. " " .. word
        else
            out[#out + 1] = cur
            cur = word
            if #out == lines then break end
        end
    end
    if #out < lines and cur ~= "" then out[#out + 1] = cur end
    for i, l in ipairs(out) do
        if #l > w then out[i] = l:sub(1, math.max(1, w - 1)) .. "…" end
    end
    return out
end

local function ass_escape(s)
    return s:gsub("\\", "\\\28"):gsub("{", "\\{"):gsub("}", "\\}"):gsub("\28", "")
end

local function get_osd_size()
    local w, h = mp.get_osd_size()
    if not w or w == 0 or not h or h == 0 then return 1920, 1080 end
    return w, h
end

local function render()
    if not visible then return end
    local ow, oh = get_osd_size()
    overlay.res_x, overlay.res_y = ow, oh

    -- fit the keyboard, reserving room for the title above it
    local unit = math.min(ow * 0.96 / UNITS_W, oh * 0.9 / (UNITS_H + 1.1))
    local kb_w, kb_h = UNITS_W * unit, UNITS_H * unit
    local ox = (ow - kb_w) / 2
    local oy = (oh - kb_h) / 2 + unit * 0.45
    local gap = unit * 0.08
    local ks = unit - gap                       -- drawn key side
    local fs_key = unit * 0.30
    local fs_act = math.max(9, unit * 0.155)
    local act_cpl = math.max(3, math.floor(ks / (fs_act * 0.52))) -- chars per line

    local map = build_map()
    local a = assdraw.ass_new()

    -- dim backdrop
    a:new_event()
    a:append(string.format("{\\pos(0,0)\\an7\\bord0\\shad0\\1c&H%s&\\1a&H66&\\p1}", COL.bg))
    a:draw_start()
    a:rect_cw(0, 0, ow, oh)
    a:draw_stop()

    -- title / legend
    local names = { base = "BASE", shift = "SHIFT", alt = "ALT", ctrl = "CTRL" }
    a:new_event()
    a:append(string.format(
        "{\\pos(%d,%d)\\an5\\fs%d\\bord1\\3c&H000000&\\1c&H%s&}Keybindings  ·  layer: %s  ·  1 base  2 shift  3 alt  4 ctrl  ·  Esc/F1 close",
        ox + kb_w / 2, oy - unit * 0.55, math.floor(unit * 0.26), COL.title, names[layer]))

    for _, row in ipairs(ROWS) do
        local x = ox
        local ky = oy + row.y * unit
        for _, k in ipairs(row.keys) do
            if k.spacer then
                x = x + k.spacer * unit
            else
                local kw = (k.w or 1) * unit
                local name = k[1]
                local cyr = CYR[name]
                -- resolve binding for this key on the active layer
                local hit
                for _, cand in ipairs(candidates(name, cyr, layer)) do
                    local m = map[normalize(cand)]
                    if m then hit = m; break end
                end

                -- key body
                a:new_event()
                a:append(string.format("{\\pos(0,0)\\an7\\shad0\\bord%d\\3c&H%s&\\1c&H%s&\\1a&H14&\\p1}",
                    hit and 3 or 1,
                    hit and COL.accent or COL.key_bord,
                    hit and COL.bound or COL.key))
                a:draw_start()
                a:rect_cw(x, ky, x + kw - gap, ky + ks)
                a:draw_stop()

                -- key legend (top-left)
                a:new_event()
                a:append(string.format("{\\pos(%d,%d)\\an7\\fs%d\\bord1\\3c&H000000&\\1c&H%s&}%s",
                    math.floor(x + ks * 0.14), math.floor(ky + ks * 0.10),
                    math.floor(fs_key), hit and COL.label or COL.dim, ass_escape(k[2])))

                -- action label (lower area, wrapped)
                if hit then
                    local lines = wrap(clean(hit), math.floor(act_cpl * (k.w or 1)), 3)
                    if #lines > 0 then
                        a:new_event()
                        a:append(string.format("{\\pos(%d,%d)\\an1\\fs%d\\bord1\\3c&H000000&\\1c&H%s&}%s",
                            math.floor(x + ks * 0.12), math.floor(ky + ks - ks * 0.12),
                            math.floor(fs_act), COL.action, ass_escape(table.concat(lines, "\\N"))))
                    end
                end
                x = x + kw
            end
        end
    end

    overlay.data = a.text
    overlay:update()
end

local function set_layer(l)
    return function()
        layer = l
        render()
    end
end

local function add_forced(key, name, fn)
    mp.add_forced_key_binding(key, name, fn)
    forced[#forced + 1] = name
end

local function hide()
    if not visible then return end
    visible = false
    for _, n in ipairs(forced) do mp.remove_key_binding(n) end
    forced = {}
    mp.unobserve_property(render)
    if overlay then overlay:remove() end
end

local function show()
    if visible then return end
    visible = true
    layer = "base"
    overlay = overlay or mp.create_osd_overlay("ass-events")
    add_forced("ESC", "kbd-esc", hide)
    add_forced("1", "kbd-l1", set_layer("base"))
    add_forced("2", "kbd-l2", set_layer("shift"))
    add_forced("3", "kbd-l3", set_layer("alt"))
    add_forced("4", "kbd-l4", set_layer("ctrl"))
    mp.observe_property("osd-dimensions", "native", render)
    render()
end

local function toggle()
    if visible then hide() else show() end
end

mp.add_key_binding(nil, "toggle", toggle)
