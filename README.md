# Neovim configuration

Lua configuration using locally vendored plugins and Lazy.nvim. Use Neovim
0.11+; the vendored nvim-lspconfig recommends 0.11.3+ (basic attachment is also
tested on this machine's 0.11.0).

## File explorer

Oil opens automatically for directory buffers (`nvim .`). Press `-` or
`<Space>e` to browse the current file's parent directory. Inside Oil, press
Enter to open an entry, `-` to go up, and `g?` for help. Hidden files are shown.
Edit filenames and save with `:w` to apply filesystem changes.

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
