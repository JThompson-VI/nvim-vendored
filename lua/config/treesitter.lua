local parser_dir = vim.fn.stdpath("data") .. "/treesitter"
local languages = {
  "lua", "python", "javascript", "typescript", "tsx", "c", "cpp",
  "go", "gomod", "gosum", "gowork",
  "vue", "html", "css", "scss",
  "json", "markdown", "markdown_inline", "vim", "vimdoc", "query",
}

-- Prefer parsers built against the vendored queries over Neovim's bundled ones.
vim.opt.runtimepath:prepend(parser_dir)

require("nvim-treesitter.configs").setup({
  parser_install_dir = parser_dir,
  ensure_installed = {},
  auto_install = false,
  highlight = { enable = true, additional_vim_regex_highlighting = false },
  indent = { enable = false },
  incremental_selection = { enable = false },
})

vim.api.nvim_create_user_command("TSInstallConfigured", function()
  -- Explicit setup only: downloads revisions from the vendored lockfile.
  require("nvim-treesitter.install").update({ with_sync = true })(languages)
  local missing = {}
  for _, language in ipairs(languages) do
    if vim.fn.filereadable(parser_dir .. "/parser/" .. language .. ".so") ~= 1 then
      missing[#missing + 1] = language
    end
  end
  if #missing > 0 then
    error("Tree-sitter parsers not installed: " .. table.concat(missing, ", "))
  end
end, { desc = "Install/update configured Tree-sitter parsers (requires network and C compiler)" })
