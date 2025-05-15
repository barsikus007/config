-- ^C to copy
vim.keymap.set('n', '<C-c>', '"+y', { noremap = true })
vim.keymap.set('v', '<C-c>', '"+y', { noremap = true })

-- https://github.com/neovide/neovide/issues/1282#issuecomment-2496204257
-- TODO make it global?
if vim.g.neovide then
	vim.api.nvim_set_keymap('n', '<C-v>', 'l"+P', {noremap = true})
	vim.api.nvim_set_keymap('v', '<C-v>', '"+P', {noremap = true})
	vim.api.nvim_set_keymap('c', '<C-v>', '<C-o>l<C-o>"+<C-o>P<C-o>l', {noremap = true})
	vim.api.nvim_set_keymap('i', '<C-v>', '<ESC>l"+Pli', {noremap = true})
	vim.api.nvim_set_keymap('t', '<C-v>', '<C-\\><C-n>"+Pi', {noremap = true})
    vim.api.nvim_set_keymap("i", "<C-v>", '<ESC>"+p', { noremap = true }) -- Paste in insert mode (CTRL+C)
    vim.api.nvim_set_keymap("n", "<C-v>", '"+p', { noremap = true }) -- Paste in normal mode (CTRL+C)
end

-- russian commands
-- https://neovim.io/doc/user/russian.html
-- https://gist.github.com/sigsergv/5329458
-- TODO https://habr.com/ru/articles/726400/
local function escape(str)
    -- Эти символы должны быть экранированы, если встречаются в langmap
    local escape_chars = [[;,."|\]]
    return vim.fn.escape(str, escape_chars)
end

local ru = [[ЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ,ёйцукенгшщзхъфывапролджэячсмить]]
local en = [[~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>?`qwertyuiop[]asdfghjkl;'zxcvbnm]]
vim.opt.langmap = escape(ru) .. ";" .. escape(en)

local map = vim.keymap.set
local function nmap(shortcut, command)
    map('n', shortcut, command)
end
nmap("Ж", ":")
-- yank
nmap("Н", "Y")
nmap("з", "p")
nmap("ф", "a")
nmap("щ", "o")
nmap("г", "u")
nmap("З", "P")
