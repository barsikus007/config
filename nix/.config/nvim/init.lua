--? code style
vim.cmd("syntax on")                 --? by default in nvim
vim.cmd("filetype plugin indent on") --? by default in nvim
vim.o.encoding = "UTF-8"             --? by default in nvim
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


--? keymaps
vim.g.mapleader = " "

--? ^c to copy; ^v to paste
vim.keymap.set('n', '<C-c>', '"+y', { noremap = true })
vim.keymap.set('v', '<C-c>', '"+y', { noremap = true })
--! https://github.com/neovide/neovide/issues/1282#issuecomment-2496204257
if vim.g.neovide then
    vim.api.nvim_set_keymap('n', '<C-v>', '"+p', { noremap = true })
    vim.api.nvim_set_keymap('v', '<C-v>', '"+P', { noremap = true })
    vim.api.nvim_set_keymap('c', '<C-v>', '<C-R>+', { noremap = true })
    vim.api.nvim_set_keymap('i', '<C-v>', '<ESC>"+p', { noremap = true })
    vim.api.nvim_set_keymap('t', '<C-v>', '<C-\\><C-n>"+Pi', { noremap = true })
end

--? russian commands
-- TODO https://habr.com/ru/articles/726400/
local function escape(str)
    --? Эти символы должны быть экранированы, если встречаются в langmap
    local escape_chars = [[;,."|\]]
    return vim.fn.escape(str, escape_chars)
end

local ru = [[ЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ,ёйцукенгшщзхъфывапролджэячсмить]]
local en = [[~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>?`qwertyuiop[]asdfghjkl;'zxcvbnm]]
vim.o.langmap = escape(ru) .. ";" .. escape(en)

--! https://gist.github.com/sigsergv/5329458
local map = vim.keymap.set
-- like ":map" but for Normal mode
local function nmap(shortcut, command)
    map("n", shortcut, command)
end
nmap("Ж", ":")
nmap("Н", "Y")
nmap("з", "p")
nmap("ф", "a")
nmap("щ", "o")
nmap("г", "u")
nmap("З", "P")
