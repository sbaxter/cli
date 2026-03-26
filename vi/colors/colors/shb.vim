" Name:         shb
" Description:  This color scheme is mine.
" Author:       Seth Baxter <me@sethbaxter.com>
" Maintainer:   Seth Baxter <me@sethbaxter.com>
" Website:      https://github.com/sbaxter/cli
" License:      Same as Vim
" Last Updated: Wed May 23 08:40:22 2022

set background=dark

hi clear
let g:colors_name = 'shb'

let s:t_Co = exists('&t_Co') && !empty(&t_Co) && &t_Co > 1 ? &t_Co : 1

" only supports xterm-256 for now
if s:t_Co >= 256
  " normal text
  hi Normal ctermfg=10 ctermbg=NONE cterm=NONE
  " "TODO/FIXME"
  hi Todo ctermfg=0 ctermbg=3 cterm=NONE
  " /keyword
  hi Search ctermfg=7 ctermbg=12 cterm=NONE
  " :s/keyword/replace/
  hi IncSearch ctermfg=7 ctermbg=12 cterm=NONE
  " Line numbers
  hi LineNr ctermfg=130 ctermbg=NONE cterm=NONE
  " Column highlight (e.g. highlight 80th col)
  hi ColorColumn ctermfg=NONE ctermbg=232 cterm=NONE
  " command errors (e.g. "Pattern not found")
  hi ErrorMsg ctermfg=7 ctermbg=1 cterm=NONE
  " command warnings (e.g. "search hit BOTTOM, continuing at TOP")
  hi WarningMsg ctermfg=7 ctermbg=1 cterm=NONE
  " paren/braces match highlight
  hi MatchParen ctermfg=15 ctermbg=6 cterm=NONE
  " underlined text
  hi Underlined ctermfg=12 ctermbg=NONE cterm=underline
  " comments
  hi Comment ctermfg=4 ctermbg=NONE cterm=NONE
  " syntax errors
  hi Error ctermfg=7 ctermbg=1 cterm=NONE
  " any constants
  hi Constant ctermfg=1 ctermbg=NONE cterm=NONE
  " boolean constants, specifically
  hi Boolean ctermfg=3 ctermbg=NONE cterm=NONE
  " any variable name
  hi Identifier ctermfg=6 ctermbg=NONE cterm=NONE
  " any statement
  hi Statement ctermfg=3 ctermbg=NONE cterm=NONE
  " any special symbol
  hi Special ctermfg=5 ctermbg=NONE cterm=NONE
  " generic Preprocessor
  hi PreProc ctermfg=5 ctermbg=NONE cterm=NONE
  " int, long, char, etc.
  hi Type ctermfg=23 ctermbg=NONE cterm=NONE
  " directory names (and other special names in listings)
  hi Directory ctermfg=2 ctermbg=NONE cterm=NONE
  " titles for output from ":set all", ":autocmd" etc.
  hi Title ctermfg=5 ctermbg=NONE cterm=NONE

  " Just underline
  hi SpellBad ctermfg=NONE ctermbg=NONE cterm=underline
  hi SpellCap ctermfg=NONE ctermbg=NONE cterm=underline
  hi SpellLocal ctermfg=NONE ctermbg=NONE cterm=underline
  hi SpellRare ctermfg=NONE ctermbg=NONE cterm=underline
  hi TabLine ctermfg=NONE ctermbg=NONE cterm=underline

  " No distinction . . . yet
  hi lCursor ctermfg=NONE ctermbg=NONE cterm=NONE
  hi CursorLineNr ctermfg=NONE ctermbg=NONE cterm=NONE
  hi Cursor ctermfg=NONE ctermbg=NONE cterm=NONE
  hi CursorLine ctermfg=NONE ctermbg=NONE cterm=NONE
  hi CursorColumn ctermfg=NONE ctermbg=NONE cterm=NONE
  hi Conceal ctermfg=NONE ctermbg=NONE cterm=NONE
  hi DiffAdd ctermfg=NONE ctermbg=NONE cterm=NONE
  hi DiffChange ctermfg=NONE ctermbg=NONE cterm=NONE
  hi DiffDelete ctermfg=NONE ctermbg=NONE cterm=NONE
  hi DiffText ctermfg=NONE ctermbg=NONE cterm=NONE
  hi EndOfBuffer ctermfg=NONE ctermbg=NONE cterm=NONE
  hi FoldColumn ctermfg=NONE ctermbg=NONE cterm=NONE
  hi Folded ctermfg=NONE ctermbg=NONE cterm=NONE
  hi Ignore ctermfg=NONE ctermbg=NONE cterm=NONE
  hi ModeMsg ctermfg=NONE ctermbg=NONE cterm=NONE
  hi MoreMsg ctermfg=NONE ctermbg=NONE cterm=NONE
  hi NonText ctermfg=NONE ctermbg=NONE cterm=NONE
  hi Pmenu ctermfg=NONE ctermbg=NONE cterm=NONE
  hi PmenuSbar ctermfg=NONE ctermbg=NONE cterm=NONE
  hi PmenuSel ctermfg=NONE ctermbg=NONE cterm=NONE
  hi PmenuThumb ctermfg=NONE ctermbg=NONE cterm=NONE
  hi Question ctermfg=NONE ctermbg=NONE cterm=NONE
  hi QuickFixLine ctermfg=NONE ctermbg=NONE cterm=NONE
  hi SignColumn ctermfg=NONE ctermbg=NONE cterm=NONE
  hi SpecialKey ctermfg=NONE ctermbg=NONE cterm=NONE
  hi StatusLine ctermfg=NONE ctermbg=NONE cterm=NONE
  hi StatusLineNC ctermfg=NONE ctermbg=NONE cterm=NONE
  hi StatusLineTerm ctermfg=NONE ctermbg=NONE cterm=NONE
  hi StatusLineTermNC ctermfg=NONE ctermbg=NONE cterm=NONE
  hi TabLineFill ctermfg=NONE ctermbg=NONE cterm=NONE
  hi TabLineSel ctermfg=NONE ctermbg=NONE cterm=NONE
  hi ToolbarLine ctermfg=NONE ctermbg=NONE cterm=NONE
  hi ToolbarButton ctermfg=NONE ctermbg=NONE cterm=NONE
  hi VertSplit ctermfg=NONE ctermbg=NONE cterm=NONE
  hi Visual ctermfg=NONE ctermbg=NONE cterm=NONE
  hi VisualNOS ctermfg=NONE ctermbg=NONE cterm=NONE
  hi WildMenu ctermfg=NONE ctermbg=NONE cterm=NONE

  unlet s:t_Co
  finish
endif
