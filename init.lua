if vim.fn.has("nvim-0.12") ~= 1 then
  error("This configuration requires Neovim 0.12 or newer. See README.md for installation steps.")
end

require("keymaps")
require("options")
require("autocmds")

require("config.lazy")
