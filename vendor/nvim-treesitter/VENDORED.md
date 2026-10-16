# Vendored nvim-treesitter

- Upstream: https://github.com/nvim-treesitter/nvim-treesitter
- Branch: master (Neovim 0.11-compatible implementation)
- Commit: cf12346a3414fa1b06af75c79faebe7f76df080a
- Source: complete Git archive of the commit; no upstream modifications.
- License: Apache-2.0 (see LICENSE).

Parser source revisions are pinned by the upstream lockfile.json. Grammar
sources and compiled parsers are not vendored. Run `:TSInstallConfigured`
after changing this plugin revision to synchronize selected parsers.

Keep plugin queries and parsers in sync. The incompatible main branch targets
newer Neovim versions and is not a drop-in update for this configuration.
