" vim-zsh — indentation for zshrs buffers
"
" A standalone indenter for zshrs's shell block grammar. Increases indent
" after a line that opens a block — a trailing `{`, `(`, `[`, or a shell
" block word (`do`, `then`, `in` for case, `{`) — and dedents a line that
" begins with a closing delimiter or block-end word (`}`, `)`, `]`, `done`,
" `fi`, `esac`, `else`, `elif`, `;;`).

if exists('b:did_indent')
  finish
endif
let b:did_indent = 1

setlocal autoindent
setlocal nolisp
setlocal nosmartindent
setlocal indentexpr=GetZshrsIndent()
setlocal indentkeys=0{,0},0),0],o,O,e,=then,=do,=else,=elif,=fi,=done,=esac,=;;,!^F

let b:undo_indent = 'setlocal autoindent< lisp< smartindent< indentexpr< indentkeys<'

" Only define the function once.
if exists('*GetZshrsIndent')
  finish
endif

function! GetZshrsIndent() abort
  let l:prevlnum = prevnonblank(v:lnum - 1)
  if l:prevlnum == 0
    return 0
  endif

  let l:prevline = getline(l:prevlnum)
  let l:curline = getline(v:lnum)
  let l:ind = indent(l:prevlnum)
  let l:sw = shiftwidth()

  " Strip a trailing comment for opener detection.
  let l:prevcode = substitute(l:prevline, '\s*#.*$', '', '')

  " Indent one level deeper after a line that ends by opening a block,
  " paren, or bracket.
  if l:prevcode =~# '[{[(]\s*$'
    let l:ind += l:sw
  endif

  " Indent after a shell block-opening word at end of line:
  "   ... do | ... then | case ... in | else | elif ... ; then handled above
  if l:prevcode =~# '\<\%(do\|then\|else\|in\)\s*$'
    let l:ind += l:sw
  endif
  " `elif ... ; then` / a fresh `elif`/`else` increases the body indent.
  if l:prevcode =~# '^\s*\%(else\|elif\)\>' && l:prevcode !~# '\<then\s*$'
    let l:ind += l:sw
  endif

  " Dedent a line that starts with a closing delimiter or block-end word.
  if l:curline =~# '^\s*[)}\]]'
    let l:ind -= l:sw
  endif
  if l:curline =~# '^\s*\%(done\|fi\|esac\|else\|elif\|;;\)\>'
    let l:ind -= l:sw
  endif

  return l:ind < 0 ? 0 : l:ind
endfunction
