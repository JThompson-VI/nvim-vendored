-- Run after installing parsers and building telescope-fzf-native:
-- nvim --headless -i NONE -n '+luafile tests/smoke.lua' '+qa!'
local ok, err = xpcall(function()
  assert(vim.fn.has("nvim-0.12") == 1)
  assert(vim.g.colors_name == "everforest")
  assert(require("blink.cmp").get_lsp_capabilities().textDocument.completion)
  assert(require("which-key"))
  assert(vim.fn.exists(":Bdelete") == 2)
  -- Parser samples are unnamed buffers, not language-server projects.
  for _, server in ipairs({ "clangd", "gopls", "lua_ls", "pyright", "ts_ls" }) do
    vim.lsp.enable(server, false)
  end

  local samples = {
    lua = { "lua", "local x = 1" },
    python = { "python", "x = 1" },
    javascript = { "javascript", "const x = 1;" },
    javascriptreact = { "javascript", "const x = <div />;" },
    typescript = { "typescript", "const x: number = 1;" },
    typescriptreact = { "tsx", "const x = <div />;" },
    c = { "c", "int x = 1;" },
    cpp = { "cpp", "int x = 1;" },
    go = { "go", "package main\nfunc main() {}" },
    gomod = { "gomod", "module example.com/test\ngo 1.27" },
    gosum = { "gosum", "example.com/test v1.0.0 h1:abc=" },
    gowork = { "gowork", "go 1.27\nuse ./app" },
    vue = { "vue", '<template><div>{{ message }}</div></template>\n<script lang="ts">const message: string = "hello";</script>\n<style>.x { color: red; }</style>' },
    html = { "html", "<div>Hello</div>" },
    css = { "css", ".x { color: red; }" },
    scss = { "scss", "$color: red; .x { color: $color; }" },
    json = { "json", '{"x": 1}' },
    markdown = { "markdown", "# Title\n\n`inline`\n\n```python\nx = 1\n```" },
    markdown_inline = { "markdown_inline", "Some `inline` text" },
    vim = { "vim", "let x = 1" },
    help = { "vimdoc", "*example* Help text" },
    query = { "query", "(identifier) @variable" },
  }
  local buffers = {}
  for filetype, sample in pairs(samples) do
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(sample[2], "\n", { plain = true }))
    vim.bo[buf].filetype = filetype
    local parser = assert(vim.treesitter.get_parser(buf, sample[1]), filetype)
    parser:parse(true)
    assert(vim.treesitter.highlighter.active[buf], "No highlighter: " .. filetype)
    assert(vim.treesitter.query.get(sample[1], "highlights"), filetype)
    assert(vim.wo.foldmethod == "manual", "Folding behavior changed")
    assert(not vim.bo[buf].indentexpr:find("nvim%-treesitter"), "Tree-sitter indentation enabled")
    buffers[filetype] = { buf = buf, parser = parser }
    vim.bo[buf].modified = false
  end
  assert(buffers.vue.parser:children().typescript, "Vue TypeScript injection")
  assert(buffers.vue.parser:children().css, "Vue CSS injection")
  assert(buffers.markdown.parser:children().python, "Markdown Python injection")
  assert(buffers.markdown.parser:children().markdown_inline, "Markdown inline injection")
  print("Configured parsers, JSX/TSX, injections, and highlighting passed")

  local sorter = require("telescope").extensions.fzf.native_fzf_sorter()
  sorter:_init()
  assert(sorter:scoring_function("nvim", "nvim/config.lua") >= 0)
  assert(sorter:scoring_function("zzzz", "nvim/config.lua") == -1)
  sorter:_destroy()
  print("Telescope native scoring passed")

  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")
  vim.fn.writefile({ "old" }, dir .. "/sample.txt")
  local function git(args)
    local cmd = { "git", "-C", dir }
    vim.list_extend(cmd, args)
    local result = vim.system(cmd, { text = true }):wait()
    assert(result.code == 0, result.stderr)
  end
  git({ "init", "-q" })
  git({ "add", "sample.txt" })
  git({ "-c", "user.name=Neovim Test", "-c", "user.email=test@example.invalid", "commit", "-qm", "fixture" })
  vim.cmd.edit(dir .. "/sample.txt")
  local buf = vim.api.nvim_get_current_buf()
  assert(vim.wait(5000, function() return vim.b[buf].gitsigns_head ~= nil end, 50), "Gitsigns attachment")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "new" })
  assert(vim.wait(5000, function()
    local hunks = require("gitsigns").get_hunks(buf)
    return hunks and #hunks > 0
  end, 50), "Gitsigns diff")
  vim.bo[buf].modified = false
  require("harpoon.mark").add_file()
  assert(require("harpoon.mark").get_length() > 0, "Harpoon mark")
  require("harpoon.mark").rm_file()
  require("oil").open(dir)
  assert(vim.wait(5000, function() return vim.bo.filetype == "oil" end, 50), "Oil directory view")
  print("Gitsigns, Harpoon, Oil, Which-key, colorscheme, and Blink startup passed")
end, debug.traceback)

if not ok then
  vim.api.nvim_err_writeln(err)
  vim.cmd("cquit 1")
end
