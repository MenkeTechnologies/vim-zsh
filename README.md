```
██╗   ██╗██╗███╗   ███╗     ███████╗███████╗██╗  ██╗
██║   ██║██║████╗ ████║     ╚══███╔╝██╔════╝██║  ██║
██║   ██║██║██╔████╔██║█████╗ ███╔╝ ███████╗███████║
╚██╗ ██╔╝██║██║╚██╔╝██║╚════╝███╔╝  ╚════██║██╔══██║
 ╚████╔╝ ██║██║ ╚═╝ ██║     ███████╗███████║██║  ██║
  ╚═══╝  ╚═╝╚═╝     ╚═╝     ╚══════╝╚══════╝╚═╝  ╚═╝
```

[![CI](https://github.com/MenkeTechnologies/vim-zsh/actions/workflows/ci.yml/badge.svg)](https://github.com/MenkeTechnologies/vim-zsh/actions/workflows/ci.yml)
[![Docs](https://img.shields.io/badge/docs-online-blue.svg)](https://menketechnologies.github.io/vim-zsh/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

### `[VIM PLUGIN // NEON SYNTAX // STANDALONE ZSHRS GRAMMAR // ALE + LSP]`

> *"Load it with pathogen. Open a `.zsh`. It lights up."*

Vim / Neovim support for **[zshrs](https://github.com/MenkeTechnologies/zshrs)** — the Rust rewrite of zsh, the first compiled Unix shell. Standalone syntax highlighting, filetype detection, shell-block-aware indentation, ALE linting, and vim-lsp / coc.nvim integration. Zero configuration. The filetype is `zshrs` (not `zsh`), so Vim's bundled zsh highlighter is never clobbered.

```bash
cd ~/.vim/bundle && git clone https://github.com/MenkeTechnologies/vim-zsh   # pathogen
```

### [`Read the Docs`](https://menketechnologies.github.io/vim-zsh/) &middot; [`Engineering Report`](https://menketechnologies.github.io/vim-zsh/report.html) · [`zshrs`](https://github.com/MenkeTechnologies/zshrs) · [`vim-stryke`](https://github.com/MenkeTechnologies/vim-stryke)

---

## [0x00] OVERVIEW

**vim-zsh** is Vim / Neovim support for **zshrs** — the Rust rewrite of zsh (the first compiled Unix shell). It ships as a standard Vim runtime tree, so **pathogen / vim-plug / native packages** add it to `runtimepath` with zero special handling and zero configuration.

The syntax file is a **standalone zshrs grammar** — not a reskin of Vim's bundled `zsh` / `perl` syntax. It is **generated** (`scripts/gen_syntax.sh`) directly from the zshrs binary's own reflection tables (`zshrs --dump-reflection`), so it carries the complete shell surface and never drifts:

- **137 builtins** — `.builtins`, minus the extension and keyword names
- **113 zshrs extensions** — `.extensions`, the zshrs-specific additions, in their own highlight group
- **245 special variables** — `.special_vars`
- **24 control + 10 declaration keywords** — the shell grammar (static)

Regenerate after a zshrs upgrade with `./scripts/gen_syntax.sh`.

> The `zshrs` binary must be on `$PATH` for linting and LSP. Build **[zshrs](https://github.com/MenkeTechnologies/zshrs)**.

---

## [0x01] FEATURE MATRIX

| Capability | Status |
|---|---|
| Filetype detection — extensions | **Implemented** — `*.zsh` `*.zshenv` `*.zprofile` `*.zlogin` `*.zlogout` `*.zsh-theme` become `filetype=zshrs` |
| Filetype detection — dotfiles | **Implemented** — `.zshrc` `.zshenv` `.zprofile` `.zlogin` `.zlogout` `.zpreztorc` |
| Filetype detection — shebang | **Implemented** — extensionless scripts with `#!/usr/bin/env zsh` (or `zshrs`) are detected |
| Syntax highlighting | **Implemented** — standalone grammar from zshrs's reflection (builtins, extensions, special vars, keywords, sigils, strings, here-docs, command substitution) |
| Indentation | **Implemented** — shell-block-aware indenter (braces + `do`/`done`/`if`/`fi`/`case`/`esac`/`then`/`else`/`elif`) |
| Comments | **Implemented** — `commentstring=# %s`, `comments=:#`, comment-continuation `formatoptions` |
| Linting | **Implemented** — ALE linter running `zshrs -n` |
| Language server (vim-lsp) | **Implemented** — `zshrs --lsp`, allowlisted for `zshrs` + `zsh` |
| Language server (coc.nvim) | **Implemented** — ready-to-paste `languageserver` config |
| Help | **Implemented** — `:help vim-zsh` |
| Config required | **None** — two opt-outs to disable ALE or LSP wiring |

---

## [0x02] INSTALL

**pathogen**

```bash
cd ~/.vim/bundle
git clone https://github.com/MenkeTechnologies/vim-zsh
# then inside vim:  :Helptags
```

**vim-plug** (add to `~/.vimrc` / `init.vim`)

```vim
Plug 'MenkeTechnologies/vim-zsh'
```

**native packages** (Vim 8+ / Neovim)

```bash
git clone https://github.com/MenkeTechnologies/vim-zsh \
    ~/.vim/pack/plugins/start/vim-zsh
```

Open any `.zsh` file and it lights up — no further configuration. See `:help vim-zsh`.

---

## [0x03] SYNTAX // TOKEN CATEGORIES

The grammar is generated from the zshrs binary's own reflection tables (`zshrs --dump-reflection`):

| Category | Tokens (sample) | Highlight |
|---|---|---|
| Declarations (10) | `declare` `export` `float` `integer` `let` `local` `readonly` `set` `shift` `typeset` | `StorageClass` |
| Control flow (24) | `if` `elif` `else` `fi` `for` `foreach` `while` `until` `do` `done` `case` `esac` `function` `select` `repeat` `return` | `Statement` |
| Builtins (137) | `bindkey` `cd` `echo` `print` `read` `setopt` `unsetopt` `zmodload` `zle` `zstyle` `autoload` `bg` `fg` `jobs` | `Function` |
| Extensions (113) | `async` `await` `spawn` `barrier` `arch` `base64` `fold` … (zshrs-specific) | `PreProc` |
| Special variables (245) | `PATH` `HOME` `PWD` `ZSH_VERSION` `RANDOM` `LINENO` `SECONDS` `HISTFILE` | `Identifier` |
| Sigil variables | `$name` `${...}` `$1` `$#` `$@` `$?` `$!` `$$` `$*` `$-` | `Identifier` |

Single / double quoted strings with `$var` / `${...}` interpolation and escapes, backtick and `$(...)` command substitution, here-docs (`<<EOF` / `<<-` / `<<'EOF'`), numbers, comments, and the shebang are all handled. Everything links to standard highlight groups, so every colorscheme covers it.

The **extensions** get their own highlight group (`zshrsExtension` → `PreProc`) — these are the zshrs-specific builtins that don't exist in upstream zsh, so they stand out from the POSIX/zsh builtin set.

---

## [0x04] LINTING (ALE)

When **[ALE](https://github.com/dense-analysis/ale)** is installed, vim-zsh registers a linter that runs:

```bash
zshrs -n
```

on the buffer (passed on stdin). zshrs's no-exec parse check reports a parse error as `zsh: <reason>` / `zsh: parse error near ...` on stderr with a non-zero exit; the handler surfaces it inline. Skipped silently if ALE is absent or `g:vim_zsh_no_ale` is set.

---

## [0x05] LANGUAGE SERVER

### vim-lsp

Registered automatically as `zshrs --lsp`, allowlisted for the `zshrs` and `zsh` filetypes — no extra config when **[vim-lsp](https://github.com/prabirshrestha/vim-lsp)** is installed.

### coc.nvim

Add to `coc-settings.json`:

```json
{
  "languageserver": {
    "zshrs": {
      "command": "zshrs",
      "args": ["--lsp"],
      "filetypes": ["zshrs", "zsh"]
    }
  }
}
```

---

## [0x06] OPTIONS

Set before the plugin loads (e.g. in your `vimrc`):

| Variable | Effect |
|---|---|
| `let g:vim_zsh_no_ale = 1` | Skip ALE linter registration |
| `let g:vim_zsh_no_lsp = 1` | Skip vim-lsp server registration |

---

## [0x07] LAYOUT

```
vim-zsh/
├── ftdetect/zshrs.vim   # *.zsh + dotfiles + zsh shebang -> filetype=zshrs
├── syntax/zshrs.vim     # standalone zshrs grammar (generated; 137 builtins, 113 extensions, 245 special vars)
├── scripts/gen_syntax.sh # regenerates syntax/zshrs.vim from `zshrs --dump-reflection`
├── ftplugin/zshrs.vim   # commentstring '# %s', comments, formatoptions
├── indent/zshrs.vim     # standalone shell-block-aware indenter
├── plugin/zshrs.vim     # ALE linter + vim-lsp + coc wiring
└── doc/zshrs.txt        # :help vim-zsh
```

Standard Vim runtime layout — pathogen / vim-plug / native packages add it to `runtimepath` with no special handling.

---

## [0x08] LICENSE

MIT © **[MenkeTechnologies](https://github.com/MenkeTechnologies)**
