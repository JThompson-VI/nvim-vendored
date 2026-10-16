# Vendored telescope-fzf-native.nvim

- Upstream: https://github.com/nvim-telescope/telescope-fzf-native.nvim
- Commit: b25b749b9db64d375d782094e2b9dce53ad53a40
- Source: complete Git archive of the commit; no upstream modifications.
- License: MIT (see LICENSE).

Build locally with `make -C vendor/telescope-fzf-native.nvim` from the Neovim
configuration directory. Requires make and a C compiler. The generated library
in `build/` is ignored by Git and must be rebuilt on each machine.

To update, replace the upstream archive contents, preserve this provenance
file, update the commit above, and rebuild the library.
