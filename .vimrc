" vim:ts=8
" $Id: vimrc,v 1.7 2007/02/24 00:06:03 holsta Exp $
version 7.0 

set noautoindent "Don't Auto Indent by default
set autowrite " Write to file when you switch out, also on :make
set background=dark "I usually have a black background
set backspace=indent,eol,start 
set cino=>1s "my kinda c indentation
set nobackup " get AWAY FROM ME with those automatic backups
set nocompatible "Break VI cloning
set complete=.,b,u,k,] " :h complete to find out where CTRL - {p,n} looks
set dictionary=/usr/share/dict/words "ctrl-x, ctrl-k dictionary word completion

"Recognize gcc error formats
set efm=%f:%l:\ %m,In\ file\ included\ from\ %f:%l:,\^I\^Ifrom\ %f:%l%m
set noexpandtab "Use real tabs instead of spaces
set helpheight=0 "Help screen defaults to half of the current window
set hidden
set hlsearch "highlight stuff you search for
set iskeyword=@,48-57,_,192-255,-,. "add - and . as keyword characters
"set keywordprg "K runs man on the current word by default
set laststatus=2 "We want the status line
set mef=~/tmp/m-error## "Name of :make error files

"These are all in my paths, trust me I want them all :)
set path=.,./include,../include,/usr/include,/usr/local/include,~
set report=0 "Show all changes for : commands
set ruler "Show cursor position at all times
set scrolljump=1 "How many lines to jump when you scroll off the window
set scrolloff=3 "Minimum distance of cursor from edge of screen
set shell=/bin/sh
set shiftwidth=8 "Space to use for (auto)indent
set shortmess=atI "Shorten status messages
set showmatch " show matching bracket briefly
set sidescroll=0 "How far to scroll sideways at a time
set smartcase "Smarter than ignore case
set smarttab "shiftwidth and tabstop tabbing
set splitbelow "I like new windows to appear on the bottom
set tabstop=8 "How wide a tab is
set textwidth=0 "Maximum text width
set notitle "Don't set Xterm titles
set viminfo=%,'50,\"100,:100,n~/.viminfo ".viminfo file settings
set wildchar=<TAB> "Command Line completion uses <TAB>
set winheight=12 "Current window is always at least 12 lines tall
set nowrap 
set wrapmargin=0 "textwidth in reverse
set nowriteany "use ! verification for dodgy file writes
"set encoding=utf-8
syntax on

" support for folding
set foldenable
set foldmethod=marker

" don't pollute directories with swap files, keep them in one place
" inspired by jcs
silent !mkdir -p ~/.vim/swp/
set directory=~/.vim/swp/

" highlights status line in active split"     
	hi   StatusLine     ctermbg=red      ctermfg=black       cterm=NONE
	hi   StatusLineNC   ctermbg=cyan     ctermfg=black       cterm=NONE

" mail and news, textwidth 72, tabs expanded, don't autoindent
au BufNewFile,BufReadPost mutt*,.article*,.followup,*.txt set tw=72 et noai

" Coding; autoindent, textwidth 79, show matching {}, numbers 
au BufNewFile,BufReadPost *.c,*.h,*.php,*.py,*.sh set ai tw=79 sm nu 

" For *.c and *.h files set formatting of comments and set
" C-indenting on.
au BufNewFile,BufRead *.c,*.h set formatoptions=croql cindent comments=sr:/*,mb:*,el:*/,:// ts=8 nu sw=2 ai et
au BufNewFile,BufRead Makefile,*.mk set ts=8

" cvs commit messages; wrapped at 72 and tabs get expanded
au BufNewFile,BufRead /tmp/cvs[0-9A-Z]* set tw=72 et wrap noai
