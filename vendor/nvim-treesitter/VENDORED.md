# Vendored nvim-treesitter

- Upstream: https://github.com/nvim-treesitter/nvim-treesitter
- Branch: main (Neovim 0.12 implementation)
- Commit: 29212d826054bb2948fa9d3a99eca9bf6a050eb2
- Source: complete upstream Git archive; no upstream modifications.
- License: Apache-2.0 (see LICENSE).

Parser revisions are pinned in lua/nvim-treesitter/parsers.lua. Bundled
queries live in runtime/queries; some languages obtain queries from their
pinned grammar sources. Grammar sources and compiled parsers are not vendored.
Run :TSInstallConfigured after updating this copy, then restart Neovim.
Parsers and installed queries live in stdpath("data")/treesitter-0.12.

This is the rewritten API and requires Neovim 0.12+ and Tree-sitter CLI
0.26.1+. It is not compatible with the old nvim-treesitter.configs setup.
