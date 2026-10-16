vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_lsp", { clear = true }),
  callback = function(event)
    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = desc })
    end

    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gD", vim.lsp.buf.declaration, "Go to declaration")
    map("gr", vim.lsp.buf.references, "Find references")
    map("gi", vim.lsp.buf.implementation, "Go to implementation")
    map("K", vim.lsp.buf.hover, "Hover documentation")
    map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("<leader>ld", vim.diagnostic.open_float, "Line diagnostics")
    map("<leader>lf", function()
      vim.lsp.buf.format({ bufnr = event.buf, async = true })
    end, "Format with LSP")
  end,
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
        -- Vendored plugins are dependencies, not workspace source files.
        ignoreDir = { "vendor", ".git" },
      },
      telemetry = { enable = false },
    },
  },
})

-- Server binaries remain system/project dependencies; plugin code is vendored.
-- Only enable installed servers so other machines can start without errors.
for server, executable in pairs({
  clangd = "clangd",
  lua_ls = "lua-language-server",
  pyright = "pyright-langserver",
  ts_ls = "typescript-language-server",
}) do
  if vim.fn.executable(executable) == 1 then
    vim.lsp.enable(server)
  end
end
