# Neovim configuration

Lua configuration using locally vendored plugins and Lazy.nvim. Use Neovim
0.11+; the vendored nvim-lspconfig recommends 0.11.3+ (basic attachment is also
tested on this machine's 0.11.0).

## File explorer

Oil opens automatically for directory buffers (`nvim .`). Press `-` or
`<Space>e` to browse the current file's parent directory. Inside Oil, press
Enter to open an entry, `-` to go up, and `g?` for help. Hidden files are shown.
Edit filenames and save with `:w` to apply filesystem changes.

## Telescope search

Telescope uses the vendored telescope-fzf-native extension for native fuzzy
sorting of files and other results, with smart-case matching. This builds its
own C library and does not use the `fzf` executable.

On a new machine, install make and a C compiler, then run this from the
configuration directory:

```sh
make -C vendor/telescope-fzf-native.nvim
```

Lazy.nvim also has a `make` build hook for the extension. Generated binaries
are ignored by Git. If the library is unavailable, Telescope warns and uses
its built-in Lua sorter. Rebuild and restart Neovim to enable native sorting.
The pinned upstream revision is in the extension's `VENDORED.md`.

`<Space>sf` lists files using `rg --files`, falling back to fd or find when
needed. `<Space>f` lists Git-tracked files. `<Space>sg` searches file contents
and requires ripgrep. The native sorter does not change these search tools.

## Tree-sitter highlighting

The vendored nvim-treesitter plugin uses its Neovim 0.11-compatible `master`
implementation, pinned in `vendor/nvim-treesitter/VENDORED.md`. Highlighting
is enabled; indentation, folding, and incremental selection retain their
existing behavior.

Run `:TSInstallConfigured` to install or update parsers for Lua, Python,
JavaScript/JSX, TypeScript, TSX, C, C++, JSON, Markdown (including inline
markup and code injections), Vim script, Vim help, and Tree-sitter queries.
The command downloads source revisions from the vendored parser lockfile and
compiles them locally. It requires network access, a C compiler, Git, curl,
tar, and Tree-sitter CLI 0.25.x (this machine has 0.25.3). Some grammar
generation also needs Node.js. Parsers live under `stdpath("data")/treesitter`,
outside this repository, and must be installed on each machine.

Normal startup never installs or updates parsers. Installed parsers work
offline; files without a supported parser keep ordinary syntax highlighting.
After changing the vendored plugin revision, rerun `:TSInstallConfigured`
and restart Neovim to keep parser libraries and highlighting queries aligned.
Use `:TSInstallInfo` and `:checkhealth nvim-treesitter` to diagnose missing
parsers; `:Inspect` shows highlighting under the cursor.

## Language support

The vendored nvim-lspconfig supplies server configurations. Server executables
are separate system/project dependencies; only installed servers are enabled:

| Language | Executable on PATH |
| --- | --- |
| Lua | `lua-language-server` |
| C / C++ | `clangd` |
| Python | `pyright-langserver` |
| JavaScript / TypeScript (including JSX / TSX) | `typescript-language-server` (also needs `typescript`) |

All listed servers are installed on the current machine. Plugin source stays in
`vendor/`; server runtimes stay outside this repository to avoid vendoring
platform-specific binaries and large dependency trees. Restart Neovim after
installing a server. Add further servers in `lua/config/lsp.lua`.

C and C++ use the existing Apple clangd 17 installation. The usual LSP
navigation, diagnostics, formatting, and Blink completion shortcuts apply.
`:LspClangdSwitchSourceHeader` switches between source and header files.
For projects with custom include paths, defines, or compiler flags, provide
`compile_commands.json` in the project root (for CMake, configure with
`-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` and link or copy the generated file from
the build directory to the project root). Simple projects can use
`compile_flags.txt` instead. Without either, clangd uses fallback compile flags.
See the [clangd project setup guide](https://clangd.llvm.org/installation#project-setup).

Completion uses vendored blink.cmp v1.10.2 with automatic suggestions from
LSP, filesystem paths, and words in visible buffers. Buffer words appear
alongside LSP and path results, including when no server is attached.
`Ctrl-Space` opens suggestions (or toggles documentation when already open),
`Ctrl-J` / `Ctrl-K` select the next / previous candidate, `Ctrl-Y` accepts it, and `Ctrl-E`
dismisses the menu. Nothing is preselected or inserted until requested;
Enter inserts a newline. Tab / Shift-Tab move through active snippet
placeholders. Server-provided snippets use Neovim's built-in snippet engine;
no additional snippet collection is installed.

Blink uses its Lua matcher, so startup requires no binary download or Rust
build. This trades the Rust matcher's typo resistance and performance for
portability. Command-line and terminal completion are disabled.
See `vendor/blink.cmp/VENDORED.md` for the pinned upstream revision.

LSP buffers have these shortcuts (leader is Space):

| Key | Action |
| --- | --- |
| `gd` / `gD` | Definition / declaration |
| `gr` / `gi` | References / implementation |
| `K` | Hover documentation |
| `<Space>rn` | Rename symbol |
| `<Space>ca` | Code action |
| `<Space>ld` | Line diagnostics |
| `<Space>lf` | Format using an attached server that supports formatting |
| `[d` / `]d` | Previous / next diagnostic (Neovim defaults) |

`<Space>lf` overrides the global ESLint command in LSP buffers. Pyright does
not provide formatting. Run `:LspInfo` to inspect enabled servers and clients.

Upstream documentation: [Oil](https://github.com/stevearc/oil.nvim),
[Neovim LSP](https://neovim.io/doc/user/lsp/).
