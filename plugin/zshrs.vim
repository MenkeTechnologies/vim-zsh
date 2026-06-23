" vim-zsh — language-server / linter wiring for zshrs (the Rust zsh rewrite)
"
" Flags verified against `zshrs --help` (v0.12.1):
"   -n      no-exec syntax check (parse only). On a parse error zshrs prints
"           `zsh: <reason>` / `zsh: parse error near ...` to stderr and exits 1.
"   --lsp   Language Server (JSON-RPC on stdio).
"
" Opt-outs:
"   let g:vim_zsh_no_ale = 1   " skip ALE linter registration
"   let g:vim_zsh_no_lsp = 1   " skip vim-lsp server registration

if exists('g:loaded_vim_zsh')
  finish
endif
let g:loaded_vim_zsh = 1

" ---------------------------------------------------------------------------
" ALE linter
" ---------------------------------------------------------------------------
function! ZshrsProjectRoot(buffer) abort
  let l:git = ale#path#FindNearestDirectory(a:buffer, '.git')
  return !empty(l:git) ? fnamemodify(l:git, ':h:h') : expand('#' . a:buffer . ':p:h')
endfunction

function! ZshrsHandler(buffer, lines) abort
  let l:output = []
  for l:line in a:lines
    " Form A (zsh-compatible, with line):  zshrs: <file>:<n>: <message>
    let l:m = matchlist(l:line, '\v^z%(sh|shrs):\s*.*:(\d+):\s*(.+)$')
    if !empty(l:m)
      call add(l:output, {'lnum': l:m[1] + 0, 'text': l:m[2], 'type': 'E'})
      continue
    endif
    " Form B (file-level parse error, no line): zshrs: parse error near `)'
    let l:m = matchlist(l:line, '\v^z%(sh|shrs):\s*(.+)$')
    if !empty(l:m)
      call add(l:output, {'lnum': 1, 'text': l:m[1], 'type': 'E'})
    endif
  endfor
  return l:output
endfunction

function! s:RegisterZshrsALE() abort
  if get(g:, 'vim_zsh_no_ale', 0)
    return
  endif
  if exists('*ale#linter#Define')
    " `zshrs -n` reads the buffer on stdin and reports parse errors there.
    call ale#linter#Define('zshrs', {
    \   'name': 'zshrs',
    \   'executable': 'zshrs',
    \   'command': 'zshrs -n',
    \   'read_buffer': 1,
    \   'output_stream': 'stderr',
    \   'callback': 'ZshrsHandler',
    \   'project_root': function('ZshrsProjectRoot'),
    \})
    let g:ale_linters = get(g:, 'ale_linters', {})
    let g:ale_linters.zshrs = ['zshrs']
  endif
endfunction

augroup vim_zsh_ale
  autocmd!
  autocmd VimEnter * call s:RegisterZshrsALE()
augroup END

" ---------------------------------------------------------------------------
" vim-lsp
" ---------------------------------------------------------------------------
if !get(g:, 'vim_zsh_no_lsp', 0) && exists('*lsp#register_server')
  call lsp#register_server({
  \   'name': 'zshrs',
  \   'cmd': ['zshrs', '--lsp'],
  \   'allowlist': ['zshrs', 'zsh'],
  \})
endif

" ---------------------------------------------------------------------------
" coc.nvim — add to coc-settings.json:
"   {
"     "languageserver": {
"       "zshrs": {
"         "command": "zshrs",
"         "args": ["--lsp"],
"         "filetypes": ["zshrs", "zsh"]
"       }
"     }
"   }
" ---------------------------------------------------------------------------
