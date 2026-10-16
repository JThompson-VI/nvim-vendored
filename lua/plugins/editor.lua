return {
  {
    dir = vim.fn.stdpath("config") .. "/vendor/oil.nvim",
    lazy = false,
    opts = {
      default_file_explorer = true,
      -- Keep the explorer independent of an icon plugin.
      columns = {},
      view_options = { show_hidden = true },
    },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
      { "<leader>e", "<cmd>Oil<cr>", desc = "Open file explorer" },
    },
  },
  {
    dir = vim.fn.stdpath("config") .. "/vendor/nvim-lspconfig",
    lazy = false,
    config = function()
      require("config.lsp")
    end,
  },
}
