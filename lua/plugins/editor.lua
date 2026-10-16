return {
  {
    dir = vim.fn.stdpath("config") .. "/vendor/blink.cmp",
    lazy = false,
    opts = {
      fuzzy = { implementation = "lua" },
      keymap = {
        preset = "default",
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<C-n>"] = false,
        ["<C-p>"] = false,
      },
      sources = {
        default = { "lsp", "path", "buffer" },
        providers = {
          lsp = { fallbacks = {} },
          path = { fallbacks = {} },
        },
      },
      completion = {
        list = { selection = { preselect = false, auto_insert = false } },
      },
      cmdline = { enabled = false },
      term = { enabled = false },
    },
  },
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
    dependencies = { "blink.cmp" },
    config = function()
      require("config.lsp")
    end,
  },
}
