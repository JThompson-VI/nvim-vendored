local parser_dir = vim.fn.stdpath("data") .. "/treesitter-0.12"
local languages = {
  "lua", "python", "javascript", "typescript", "tsx", "c", "cpp",
  "go", "gomod", "gosum", "gowork",
  "vue", "html", "css", "scss",
  "json", "markdown", "markdown_inline", "vim", "vimdoc", "query",
}

local supported = {}
for _, language in ipairs(languages) do supported[language] = true end

local treesitter = require("nvim-treesitter")
treesitter.setup({ install_dir = parser_dir })
vim.treesitter.language.register("javascript", "javascriptreact")
vim.treesitter.language.register("tsx", "typescriptreact")

-- Highlighting is native in 0.12; installation stays an explicit action.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
  callback = function(event)
    local language = vim.treesitter.language.get_lang(vim.bo[event.buf].filetype)
    if not supported[language] then return end
    local ok, parser = pcall(vim.treesitter.get_parser, event.buf, language)
    if ok and parser then
      vim.treesitter.start(event.buf, language)
      vim.bo[event.buf].syntax = ""
    end
  end,
})

vim.api.nvim_create_user_command("TSInstallConfigured", function()
  -- Install missing languages and dependencies, then refresh pinned revisions.
  local options = { summary = true, max_jobs = 4 }
  assert(treesitter.install(languages, options):wait(300000), "Parser installation failed; see :TSLog")
  assert(treesitter.update(languages, options):wait(300000), "Parser update failed; see :TSLog")
  for _, language in ipairs(languages) do
    assert(vim.fn.filereadable(parser_dir .. "/parser/" .. language .. ".so") == 1,
      "Missing parser: " .. language .. "; see :TSLog")
    assert(vim.treesitter.language.add(language), "Cannot load parser: " .. language)
    assert(vim.treesitter.query.get(language, "highlights"), "Missing highlight queries: " .. language)
  end
  vim.notify("Configured parsers installed. Restart Neovim to load updated parsers and queries.")
end, { desc = "Install/update configured Tree-sitter parsers (requires network, CLI, and C compiler)" })
