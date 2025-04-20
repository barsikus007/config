-- russian commands
-- https://neovim.io/doc/user/russian.html
-- https://gist.github.com/sigsergv/5329458
-- TODO https://habr.com/ru/articles/726400/
local function escape(str)
    -- Эти символы должны быть экранированы, если встречаются в langmap
    local escape_chars = [[;,."|\]]
    return vim.fn.escape(str, escape_chars)
end

local ru = [[ЁЙЦУКЕНГШЩЗХЪ/ФЫВАПРОЛДЖЭЯЧСМИТЬБЮ,ёйцукенгшщзхъфывапролджэячсмитьбю]]
local en = [[~QWERTYUIOP{}|ASDFGHJKL:"ZXCVBNM<>?`qwertyuiop[]asdfghjkl;'zxcvbnm,.]]
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
