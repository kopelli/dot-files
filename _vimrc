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
" => Handling large files
""""""""""""""""""""""""""""""""""""""""
" file is larger than 50Mb
let g:LargeFileSize = 1024 * 1024 * 50
augroup LargeFile
    autocmd BufReadPre * let f=getfsize(expand("<afile>")) | if f > g:LargeFileSize || f == -2 | call PrepareForLargeFile() | endif
augroup END

if !exists("*PrepareForLargeFile")
    function PrepareForLargeFile()
        " no syntax highlighting
        set eventignore+=FileType

        " save memory when other file is viewed
        setlocal bufhidden=unload

        " no undo possible
        setlocal undolevels=-1

        " display message
        autocmd VimEnter *  echo "The file is larger than " . (g:LargeFileSize / 1024 / 1024) . " MB, so some options are changed (see ~/.vimrc for details)."
    endfunction
endif

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

let g:rbpt_colorpairs = [
    \ ['brown',       'RoyalBlue3'],
    \ ['Darkblue',    'SeaGreen3'],
    \ ['darkgray',    'DarkOrchid3'],
    \ ['darkgreen',   'firebrick3'],
    \ ['darkcyan',    'RoyalBlue3'],
    \ ['darkred',     'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['brown',       'firebrick3'],
    \ ['gray',        'RoyalBlue3'],
    \ ['black',       'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['Darkblue',    'firebrick3'],
    \ ['darkgreen',   'RoyalBlue3'],
    \ ['darkcyan',    'SeaGreen3'],
    \ ['darkred',     'DarkOrchid3'],
    \ ['red',         'firebrick3'],
    \ ]

" Rainbow Parentheses
autocmd VimEnter * RainbowParenthesesToggleAll
autocmd Syntax *   RainbowParenthesesLoadRound
autocmd Syntax *   RainbowParenthesesLoadSquare
autocmd Syntax *   RainbowParenthesesLoadBraces
autocmd Syntax *   RainbowParenthesesLoadChevrons

""""""""""""""""""""""""""""""""""""""""
" => Status Line
""""""""""""""""""""""""""""""""""""""""
" Always show the status line
set laststatus=2

" Set to auto load a file every 1 second
"set auto_autoread=1

""""""""""""""""""""""""""""""""""""""""
" => Bundles
""""""""""""""""""""""""""""""""""""""""
let g:NERDTreeCopyCmd= 'cp -r'
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin('~/.vim/bundle')

" Let Vundle manage Vundle
" required!
Plugin 'VundleVim/Vundle.vim'

" My bundles here:
Plugin 'scrooloose/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'vim-airline/vim-airline'
Plugin 'bronson/vim-trailing-whitespace'
Plugin 'PProvost/vim-ps1'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'fxn/vim-monochrome'
Plugin 'theWildSushii/SweetCandy.vim'
Plugin 'vim-scripts/The-Vim-Gardener'
Plugin 'kien/rainbow_parentheses.vim'
"Plugin 'pangloss/vim-javascript'
"Plugin 'tpope/sensible'

"Plugin 'leafgarland/typescript-vim'
"Plugin 'groenewege/vim-less'
"Plugin 'xolox/vim-misc'
"Plugin 'xolox/vim-easytags'
"Plugin 'vim-scripts/auto_autoread.vim'
"Plugin 'leadgarland/typescript-vim'
"Plugin 'venusjs/venus.vim'
"Plugin 'majutsushi/tagbar'

" vim-scripts repos

" non-Github repos

" Git repos from local system/network
call vundle#end()           " required
filetype plugin indent on   " required
