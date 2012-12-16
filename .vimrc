" .vimrc
" Uses vundle for bundle management

set nocompatible
filetype off
set hidden

"Bundles
set rtp+=~/.vim/bundle/vundle
call vundle#rc()

" let Vundle manage Vundle
Bundle 'gmarik/vundle'
Bundle 'scrooloose/nerdtree'
Bundle 'scrooloose/nerdcommenter'
Bundle 'Lokaltog/vim-powerline'
Bundle 'taglist.vim'
Bundle 'mattn/gist-vim'
Bundle 'mattn/webapi-vim'

"Tags
let Tlist_Ctags_Cmd = "/usr/bin/ctags"
"let Tlist_WinWidth = 50
map <F4> :TlistToggle<cr>
"Toggle by F4
map <F8> :!/usr/bin/ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>

"Set to autoread
set autoread

"Enable filetype plugin
filetype plugin on
filetype indent on

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = ","
let g:mapleader = ","

"Open NERDtree
nmap <leader>n :NERDTreeToggle<cr>

set showcmd

" Ignore compiled files
set wildignore=*.o,*~,*.pyc

" Ignore case when searching
set ignorecase
" When searching try to be smart about cases
 set smartcase
" Highlight search results
set hlsearch
" Makes search act like search in modern browsers
set incsearch
" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch

" How many tenths of a second to blink when matching brackets
set mat=2


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:Powerline_symbols = 'fancy'
set laststatus=2

" Enable syntax highlighting
syntax enable

"Higlight line that goes over the 80 column limit
highlight OverLength ctermbg=red ctermfg=darkred guibg=#FFD9D9
match OverLength /\%81v.\+/

" Set extra options when running in GUI mode
if has("gui_running")
    set guioptions-=T
    set guioptions+=e
    set t_Co=256
    set guitablabel=%M\ %t
endif

if has("gui_running")
		let g:molokai_original = 1
		colorscheme molokai
else
		colorscheme molokai
endif
"set background=dark


" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac

if has('gui_running')
  set guifont=Consolas\ for\ Powerline\ 13
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Be smart when using tabs ;)
set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

" Linebreak on 500 characters
set lbr
set tw=500

"set ai "Auto indent
"set si "Smart indent
"set wrap "Wrap lines

""""""""""""""""""""""""""""""
" => Visual mode related
""""""""""""""""""""""""""""""
" Visual mode pressing * or # searches for the current selection
" Super useful! From an idea by Michael Naumann
vnoremap <silent> * :call VisualSelection('f')<CR>
vnoremap <silent> # :call VisualSelection('b')<CR>

"Set intial window size
if has('gui running')
	set guilines=30 guicolumns=100
endif

