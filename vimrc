map , !} fmt 
syntax enable
set number
set ts=2
set shiftwidth=2
set autoindent
set title
set hlsearch
au BufNewFile,BufRead *.less set filetype=less
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{CurDir()}%h\ \ \ Line:\ %l/%L:%c
