--? code style
vim.o.encoding = "UTF-8" --? by default in nvim
vim.o.fileformat = "unix"

--? visual style
vim.o.ruler = true --? by default in nvim
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.cursorline = true
vim.o.title = true
--? Show matching brackets when text indicator is over them
vim.o.showmatch = true

--? indent fix ?
vim.o.autoindent = true --? by default in nvim
vim.o.smartindent = true
vim.o.smarttab = true   --? by default in nvim
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2

--? undo behavior
-- vim.o.noswapfile = true
-- vim.o.nobackup = true
-- vim.o.undodir = "~/.vim/undodir"
-- vim.o.undofile = true
-- vim.o.clipboard = "unnamed"

--? search behavior
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true --? by default in nvim
vim.o.hlsearch = true  --? by default in nvim

--! https://www.freecodecamp.org/news/vimrc-configuration-guide-customize-your-vim-editor/
--? Make wildmenu behave like similar to Bash completion.
vim.o.wildmode = "list:longest"
--? There are certain files that we would never want to edit with Vim.
--? Wildmenu will ignore files with these extensions.
vim.o.wildignore = "*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx"


--? languages
vim.o.commentstring = "# %s"
--? json has no commentstring by default, native gc needs one (jsonc style)
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "json", "jsonc" },
    callback = function()
        vim.bo.commentstring = "// %s"
    end,
})
--? treesitter injections resolve the tag through get_lang, and the bash parser is
--? registered under "bash" only, so ```shell fences and /* shell */ nix strings are
--! silently dropped: no parser by that name, no highlight, no error either
vim.treesitter.language.register("bash", { "shell", "sh" })

vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevel = 99

vim.diagnostic.config({ virtual_lines = { current_line = true } })
vim.keymap.set('n', "gd", vim.lsp.buf.definition, { noremap = true, silent = true, desc = "Go to definition" })
--?  https://neovim.io/doc/user/lsp.html#lsp-quickstart
-- TODO: use lsp/ folder https://neovim.io/doc/user/lsp.html#_config
-- TODO: old versions fallback
--! vscode brings its own language servers, a second set from nvim only duplicates diagnostics
if not vim.g.vscode and vim.lsp.config then
    vim.lsp.config["lua_ls"] = {
        -- TODO: formatter: stylua
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = {
            "init.lua",
            ".luarc.json",
            ".luarc.jsonc",
            ".luacheckrc",
            ".stylua.toml",
            "stylua.toml",
            "selene.toml",
            "selene.yml",
            ".git",
        },
        settings = {
            Lua = {
                runtime = {
                    version = 'LuaJIT',
                },
                workspace = {
                    library = { vim.env.VIMRUNTIME },
                },
            },
        },
    }
    vim.lsp.enable({
        -- "basedpyright",
        -- "cssls",
        "lua_ls",
        -- "nixd",
        -- "ts_ls",
    })
end

--? keymaps
vim.g.mapleader = " "
--? search and replace: https://stackoverflow.com/a/676619
--! \V (very nomagic https://neovim.io/doc/user/pattern/#%2Fmagic) + escaping \ and the / delimiter makes the yanked selection
--! literal, so regex chars in it (. * [ ] $ ^ ~ /) no longer break the pattern
vim.keymap.set('v', '<C-r>',
    [["hy:%s/\V<C-r>=substitute(escape(@h,'/\'),"\n",'\\n','g')<CR>//gc<Left><Left><Left>]],
    { noremap = true })
--? ^c to copy; ^v to paste
vim.keymap.set('n', '<C-c>', '"+y', { noremap = true })
vim.keymap.set('v', '<C-c>', '"+y', { noremap = true })
--! https://github.com/neovide/neovide/issues/1282#issuecomment-2496204257
if vim.g.neovide then
    vim.api.nvim_set_keymap('n', '<C-v>', '"+p', { noremap = true })
    vim.api.nvim_set_keymap('v', '<C-v>', '"+P', { noremap = true })
    vim.api.nvim_set_keymap('c', '<C-v>', '<C-R>+', { noremap = true })
    vim.api.nvim_set_keymap('i', '<C-v>', '<C-R>+', { noremap = true })
    vim.api.nvim_set_keymap('t', '<C-v>', '<C-\\><C-n>"+Pi', { noremap = true })
end

--? russian commands
local function escape(str)
    --? Эти символы должны быть экранированы, если встречаются в langmap
    local escape_chars = [[;,."|\]]
    return vim.fn.escape(str, escape_chars)
end
local ru = [[ЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ,ёйцукенгшщзхъфывапролджэячсмить]]
local en = [[~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>?`qwertyuiop[]asdfghjkl;'zxcvbnm]]
vim.o.langmap = escape(ru) .. ";" .. escape(en)
--! https://gist.github.com/sigsergv/5329458
vim.keymap.set("n", "Ж", ":")
vim.keymap.set("n", "Н", "Y")
vim.keymap.set("n", "з", "p")
vim.keymap.set("n", "ф", "a")
vim.keymap.set("n", "щ", "o")
vim.keymap.set("n", "г", "u")
vim.keymap.set("n", "З", "P")

-- TODO: standalone: https://neovim.io/doc/user/lsp.html#lsp-quickstart; https://lazy.folke.io/installation; https://github.com/calops/hmts.nvim; https://github.com/Wansmer/langmapper.nvim

--? both are on by default in nvim, kept explicit
--! keep them last: they fire FileType for the argv buffer, and anything
--! above (vim.lsp.enable) must be registered before that happens
vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")

if vim.g.vscode then
    local vscode = require("vscode")
    local function action(name)
        return function() vscode.action(name) end
    end
    vim.keymap.set("n", "gd", action("editor.action.revealDefinition"), { noremap = true, silent = true })
    --? nvim folds are not rendered by vscode, drive its own folding instead
    vim.keymap.set("n", "za", action("editor.toggleFold"), { noremap = true, silent = true })
    vim.keymap.set("n", "zc", action("editor.fold"), { noremap = true, silent = true })
    vim.keymap.set("n", "zo", action("editor.unfold"), { noremap = true, silent = true })
    vim.keymap.set("n", "zM", action("editor.foldAll"), { noremap = true, silent = true })
    vim.keymap.set("n", "zR", action("editor.unfoldAll"), { noremap = true, silent = true })
end
