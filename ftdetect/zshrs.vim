" vim-zsh — filetype detection for zshrs source
" Loaded automatically by pathogen / vim-plug / native packages via ftdetect/.
"
" Sets filetype=zshrs (NOT zsh) so the zshrs runtime files (syntax / ftplugin /
" indent) key off `zshrs`. Vim's bundled filetype.vim already claims *.zsh and
" the zsh dotfiles as `zsh`, and ftdetect/ scripts run after filetype.vim, so
" `setf` (a no-op when a filetype is already set) would lose. We force
" `set filetype=zshrs` to take ownership of these files. Vim's own zsh syntax
" is never loaded for them, so it is not clobbered.

" By extension.
autocmd BufNewFile,BufRead *.zsh,*.zshenv,*.zprofile,*.zlogin,*.zlogout,*.zsh-theme set filetype=zshrs

" By well-known dotfile / config names (no extension).
autocmd BufNewFile,BufRead .zshrc,.zshenv,.zprofile,.zlogin,.zlogout,.zpreztorc set filetype=zshrs

" By shebang: extensionless scripts run as `#!/usr/bin/env zsh` (or zshrs).
autocmd BufNewFile,BufRead * call s:DetectZshrsShebang()

function! s:DetectZshrsShebang() abort
  if &filetype ==# 'zshrs'
    return
  endif
  " Matches both `zsh` and `zshrs` (zshrs contains the substring zsh).
  if getline(1) =~# '^#!.*\<zsh\>'
    set filetype=zshrs
  endif
endfunction
