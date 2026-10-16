# Neovim configuration

Lua configuration using locally vendored plugins and Lazy.nvim. Use Neovim
0.11+; the vendored nvim-lspconfig recommends 0.11.3+ (basic attachment is also
tested on this machine's 0.11.0).

## File explorer

Oil opens automatically for directory buffers (`nvim .`). Press `-` or
`<Space>e` to browse the current file's parent directory. Inside Oil, press
Enter to open an entry, `-` to go up, and `g?` for help. Hidden files are shown.
Edit filenames and save with `:w` to apply filesystem changes.
