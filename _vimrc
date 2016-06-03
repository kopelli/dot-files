"" Allows for folder specific .vimrc files
"set exrc
" Disallow use of :autocmd, shell, and write commands
set secure
set nocompatible
filetype off

"Testing
""""""""""""""""""""""""""""""""""""""""
" => General
""""""""""""""""""""""""""""""""""""""""
" Enable filetype plugins
filetype plugin indent on

" Set to auto read when a file is changed from the outside
set autoread

" Use the OS clipboard by default (on versions compiled with `+clipboard`)
set clipboard=unnamed

" Set the characters `;;` to trigger ESC in all modes
inoremap ;; <ESC>

" :CDC = Change to Directory of Current file
"   NOTE: the ! means "overwrite the existing command
command! CDC cd %:p:h


""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
""""""""""""""""""""""""""""""""""""""""
" Always show current position
set ruler

" Height of the command bar
set cmdheight=2

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers (incremental...)
set incsearch

" Show matching brackets when text indicator is over them
set showmatch

" Enable line numbers
set number

" Start scrolling 5 lines before the horizontal window border
set scrolloff=5

if has("gui_win32")
    set guioptions-=T
    set guifont=Input
endif

""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax enable

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Windows as the standard file type
set ffs=dos,unix,mac

""""""""""""""""""""""""""""""""""""""""
" => File type detection
""""""""""""""""""""""""""""""""""""""""
" MSBuild targets
au BufNewFile,BufRead *.targets set filetype=xml
au BufNewFile,BufRead *.ps1 set filetype=ps1
au BufNewFile,BufRead *.psm1 set filetype=ps1

""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

" Auto indent
set ai
" Smart indent
set si
" don't wrap lines
set nowrap

" Automatically remove trailing whitespace from lines
" prior to saving the file
autocmd BufWritePre *.html :%s/\s\+$//e
autocmd BufWritePre *.less :%s/\s\+$//e
autocmd BufWritePre *.js :%s/\s\+$//e
autocmd BufWritePre *.java :%s/\s\+$//e

" Auto-source this file when we write it
autocmd! BufWritePost .vimrc source %

""""""""""""""""""""""""""""""""""""""""
" => Status Line
""""""""""""""""""""""""""""""""""""""""
" Always show the status line
set laststatus=2


""""""""""""""""""""""""""""""""""""""""
" => Bundles
""""""""""""""""""""""""""""""""""""""""
set rtp+=~/vimfiles/bundle/vundle
let path='~/vimfiles/bundle'
call vundle#rc(path)

" Let Vundle manage Vundle
" required!
Bundle 'gmarik/vundle'

" My bundles here:
Bundle 'scrooloose/nerdtree'
Bundle 'majutsushi/tagbar'
	" http://majutsushi.github.io/tagbar
Bundle 'christoomey/vim-tmux-navigator'
Bundle 'bling/vim-airline'
Bundle 'Lokaltog/powerline'
Bundle 'groenewege/vim-less'
"Bundle 'leadgarland/typescript-vim'
"Bundle 'venusjs/venus.vim'
Bundle 'bronson/vim-trailing-whitespace'
Bundle 'PProvost/vim-ps1'

" vim-scripts repos

" non-Github repos

" Git repos from local system/network
