" vim ~/.vimrc file "

set nocompatible        " Use Vim defaults (much better!) "
set bs=2                " allow backspacing over everything in insert mode "
set ai                  " always set autoindenting on "
set tw=78               " always limit the width of text to 78 "
set nu                  " turn line numbering on "
set nuw=4               " line number margin "
set nobackup            " keep a backup file "
set viminfo="NONE"      " no .viminfo file "
set fileformat=unix

if $TERM == 'xterm-256color'
    "" " installed color schemes: /usr/share/vim/vim82/colors "
    set background=dark
    colorscheme elflord
    syntax on           " syntax highlighting "
else
    colorscheme default
    syntax off          " turn off syntax highlighting "

    "" " highlight LineNr term=NONE cterm=NONE gui=NONE ctermfg=NONE ctermbg=NONE "
    highlight LineNr term=NONE      " no line number coloring "
    highlight NonText term=NONE     " no empty line coloring ~ "
endif

map Q gq                " Don't use Ex mode, use Q for formatting "
