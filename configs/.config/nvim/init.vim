" code style
syntax on
filetype on
filetype plugin on
filetype indent on

set fileformat=unix
set encoding=UTF-8
" init.lua


" visual style
set number
set relativenumber
set mouse=a
set ruler
set cursorline
" Show matching brackets when text indicator is over them
set showmatch

" indent fix ?
set autoindent
set smartindent
set smarttab
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2

" undo behavior
" set noswapfile
" set nobackup
" set undodir=~/.vim/undodir
" set undofile
" set clipboard=unnamed

" search behavior
set ignorecase
set smartcase
set incsearch
" set hlsearch

" https://www.freecodecamp.org/news/vimrc-configuration-guide-customize-your-vim-editor/
" Make wildmenu behave like similar to Bash completion.
set wildmode=list:longest
" There are certain files that we would never want to edit with Vim.
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" keymaps
let mapleader = " "

" ^C to copy
nnoremap <C-c> "+y
vnoremap <C-c> "+y

" russian commands
" https://neovim.io/doc/user/russian.html
" https://gist.github.com/sigsergv/5329458
set langmap=ёйцукенгшщзхъфывапролджэячсмитьбюЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ;`qwertyuiop[]asdfghjkl\\;'zxcvbnm\\,.~QWERTYUIOP{}ASDFGHJKL:\\"ZXCVBNM<>
nmap Ж :
" yank
nmap Н Y
nmap з p
nmap ф a
nmap щ o
nmap г u
nmap З P

" vim.plug for some reason https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
