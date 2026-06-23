" vim-zsh — filetype-local settings for zshrs buffers

if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

" zshrs comments run '#' to end of line.
setlocal commentstring=#\ %s
setlocal comments=:#

" Continue the comment leader on <Enter> / o / O.
setlocal formatoptions-=t
setlocal formatoptions+=croql

" Restore on filetype change.
let b:undo_ftplugin = 'setlocal commentstring< comments< formatoptions<'
