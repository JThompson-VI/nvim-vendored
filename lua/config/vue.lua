local M = {}
local cache, warned = {}, {}
local config_dir = vim.fn.stdpath("config")
local tool_dir = vim.fn.stdpath("data") .. "/vue-tools"
local script_types = { "javascript", "javascriptreact", "typescript", "typescriptreact" }

local function read_json(path)
  local ok, value = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
  end)
  return ok and type(value) == "table" and value or {}
end

local function warn(message)
  if warned[message] then return end
  warned[message] = true
  vim.schedule(function() vim.notify(message, vim.log.levels.WARN) end)
end

function M.project(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == "" then return end
  local root = vim.fs.root(filename, { "package.json" })
  if not root then return end
  if cache[root] ~= nil then return cache[root] or nil end
  local pkg = read_json(root .. "/package.json")
  local deps = vim.tbl_extend("force", pkg.dependencies or {}, pkg.devDependencies or {})
  local info = {}
  if vim.fn.executable("node") == 1 then
    local result = vim.system({ "node", config_dir .. "/tools/vue/project.cjs", root }, { text = true }):wait(5000)
    if result.code == 0 then
      local ok, decoded = pcall(vim.json.decode, result.stdout)
      if ok then info = decoded end
    end
  end
  local override
  -- Set in init.lua before loading plugins, or in a private configuration file.
  for path, profile in pairs(vim.g.vue_project_profiles or {}) do
    path = vim.fn.expand(path)
    if root == (vim.uv.fs_realpath(path) or vim.fs.normalize(path)) then override = profile end
  end
  if not (info.vue or info.nuxt or deps.vue or deps.nuxt or override) then
    cache[root] = false
    return
  end
  local major = info.vue and tonumber(info.vue.version:match("^(%d+)"))
  if not major and info.nuxt then
    major = info.nuxt.version:match("^2%.") and 2 or 3
  end
  local profile = override or (major == 2 and "legacy" or major == 3 and "modern" or nil)
  if profile ~= "legacy" and profile ~= "modern" then
    profile = nil
  end
  local project = { root = root, profile = profile, dependencies = info }
  cache[root] = project
  return project
end

local function start(bufnr, project)
  if not project.profile then
    warn("Vue: install project dependencies or set vim.g.vue_project_profiles for " .. project.root)
    return
  end
  local base = tool_dir .. "/" .. project.profile .. "/node_modules/"
  local vue_server = base .. "@vue/language-server/bin/vue-language-server.js"
  local ts_server = base .. "typescript-language-server/lib/cli.mjs"
  if vim.fn.executable("node") ~= 1 or vim.fn.filereadable(vue_server) ~= 1
      or vim.fn.filereadable(ts_server) ~= 1 then
    warn("Vue: missing tools; run sh " .. config_dir .. "/tools/vue/install.sh and restart Neovim")
    return
  end
  local tsdk = base .. "typescript/lib"
  local ts = project.dependencies.typescript
  -- Only reuse the tested TypeScript release line; build compilers stay untouched.
  if ts and ts.version:match("^5%.9%.") then
    tsdk = ts.directory .. "/lib"
  end
  project.tsdk = tsdk
  local ts_config = vim.deepcopy(vim.lsp.config.ts_ls)
  ts_config.name = "ts_ls"
  ts_config.root_dir = project.root
  ts_config.cmd = { "node", ts_server, "--stdio" }
  ts_config.init_options = vim.tbl_deep_extend("force", ts_config.init_options or {}, {
    tsserver = { path = tsdk .. "/tsserver.js" },
    plugins = { {
      name = "@vue/typescript-plugin",
      location = base .. "@vue/typescript-plugin",
      languages = { "vue" },
      configNamespace = "typescript",
    } },
  })
  -- These configurations are started explicitly for a known application root.
  vim.lsp.start(ts_config, { bufnr = bufnr })
  if vim.bo[bufnr].filetype == "vue" then
    local vue_config = vim.deepcopy(vim.lsp.config.vue_ls)
    vue_config.name = "vue_ls"
    vue_config.root_dir = project.root
    vue_config.cmd = { "node", vue_server, "--stdio" }
    vim.lsp.start(vue_config, { bufnr = bufnr })
  end
end

function M.setup()
  local original_root = vim.lsp.config.ts_ls.root_dir
  vim.lsp.config("ts_ls", {
    root_dir = function(bufnr, on_dir)
      if not M.project(bufnr) then original_root(bufnr, on_dir) end
    end,
  })
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("user_vue", { clear = true }),
    pattern = vim.list_extend({ "vue" }, script_types),
    callback = function(event)
      local project = M.project(event.buf)
      if project then
        start(event.buf, project)
      elseif vim.bo[event.buf].filetype == "vue" then
        warn("Vue: open this file in an application with package.json and installed dependencies")
      end
    end,
  })
  vim.api.nvim_create_user_command("VueToolsInfo", function()
    local project = M.project(0)
    if not project then
      print("No Vue application detected for this buffer")
      return
    end
    print(vim.inspect({
      root = project.root,
      profile = project.profile or "unresolved",
      tools = project.profile and tool_dir .. "/" .. project.profile,
      typescript = project.tsdk,
      dependencies = project.dependencies,
    }))
  end, { desc = "Show Vue application, tool profile, and TypeScript paths" })
end

return M
