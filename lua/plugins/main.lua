return {
	{
    dir = vim.fn.stdpath("config") .. "/vendor/plenary.nvim",
    lazy = true,
	},
	{
    dir = vim.fn.stdpath("config") .. "/vendor/popup.nvim",
    lazy = true,
	},
	{
    dir = vim.fn.stdpath("config") .. "/vendor/telescope.nvim",
    dependencies = {
      "plenary.nvim",
      "popup.nvim",
      {
        dir = vim.fn.stdpath("config") .. "/vendor/telescope-fzf-native.nvim",
        build = "make",
      },
    },
        config = function()
        local telescope = require('telescope').setup {
          defaults = {
            prompt_prefix = " ",
            selection_caret = " ",
            path_display = { "smart" },
            mappings = {
              n = {
                ["q"] = function(...)
                  return require("telescope.actions").close(...)
                end,
              },
            }
          },
          extensions = {
            fzf = {
              fuzzy = true,
              override_generic_sorter = true,
              override_file_sorter = true,
              case_mode = "smart_case",
            },
          },
        }
        local ok = pcall(require('telescope').load_extension, 'fzf')
        if not ok then
          vim.notify(
            'Telescope is using its Lua sorter. Build the native sorter with: make -C '
              .. vim.fn.stdpath('config') .. '/vendor/telescope-fzf-native.nvim',
            vim.log.levels.WARN
          )
        end
        vim.keymap.set('n', '<leader>go', require('telescope.builtin').git_status, { desc = '[G]it [O]pen status' })
        vim.keymap.set('n', '<leader>f', require('telescope.builtin').git_files, { desc = '[F]iles' })
        vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
        vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
        vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
        vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
        vim.keymap.set('n', '<leader>sk', require('telescope.builtin').keymaps, { desc = '[S]earch by [G]rep' })
        vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
        vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
        vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
        vim.keymap.set('n', '<leader>tr', require('telescope.builtin').lsp_references, { desc = '[T]elescope [R]eferences' })
        vim.keymap.set('n', '<leader>sc', require('telescope.builtin').resume, { desc = '[S]earch [C]ontinue' })
        -- vim.keymap.set('n', '<leader>sm', require('telescope.builtin').marks, { desc = '[S]earch [M]arks' })
        vim.keymap.set('n', '<leader>sm',
          function()
            require('telescope.builtin').marks(require('telescope.themes').get_dropdown {
              previewer = false,
            })
          end, { desc = '[S]earch [M]arks' })

        vim.keymap.set('n', '<leader>/', function()
          -- You can pass additional configuration to telescope to change theme, layout, etc.
          require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
            -- winblend = 5,
            previewer = false,
          })
        end, { desc = '[/] Fuzzily search in current buffer' })
      end
	},
  {
    dir = vim.fn.stdpath("config") .. "/vendor/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'right_align', -- 'eol' | 'overlay' | 'right_align'
        delay = 0,
        ignore_whitespace = false,
      },

      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        map('n', '<leader>gj', gs.next_hunk, "Next Hunk")
        map('n', '<leader>gk', gs.prev_hunk, "Prev Hunk")
        map('n', '<leader>gs', gs.stage_hunk, "Stage Hunk")
        map('n', '<leader>gr', gs.reset_hunk, "Reset Hunk")
        map('n', '<leader>gS', gs.stage_buffer, "Stage buffer")
        map("n", "<leader>gR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>gl", function() gs.blame_line() end, "Blame Line")
        -- map("n", "<leader>gl", function() gs.blame_line({ full = true }) end, "Blame Line")

        -- stylua: ignore start
        --map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        --map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
        --map("n", "<leader>ghd", gs.diffthis, "Diff This")
        --map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
        --map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },
  {
    dir = vim.fn.stdpath("config") .. "/vendor/vim-bbye",
  },
  {
    dir = vim.fn.stdpath("config") .. "/vendor/which-key.nvim",
    config = function()
      require("which-key").setup({
        -- delay = 500, -- ms before which-key popup appears, increase to reduce triggering
        delay = function(ctx)
          -- no delay for marks and registers
          if ctx.plugin then return 0 end
          return 500
        end,
        plugins = {
          presets = false,
          marks = true,
          registers = true,
          spelling = {
            enabled = true,
            suggestions = 20,
          },
        },
        -- disable all presets you don't want
        spec = {
          { "<c-w>", group = false },
          { "g", group = false },
        },
      })
    end
    -- opts = function()
    --   return {
    --     plugins = {
    --       marks = true,
    --       registers = true,
    --       spelling = {
    --         enabled = true,
    --       },
    --       presets = {
    --         operators = false,    -- adds help for operators like d, y, ...
    --         motions = false,      -- adds help for motions
    --         text_objects = false, -- help for text objects triggered after entering an operator
    --         windows = false,      -- default bindings on <c-w>
    --         nav = false,          -- misc bindings to work with windows
    --         z = true,             -- bindings for folds, spelling and others prefixed with z
    --         g = false,            -- bindings for prefixed with g
    --       }
    --     },
    --     ignore_missing = true,
    --     triggers_nowait = {
    --       "'",
    --       '"',
    --     },
    --   }
    -- end,
  },
  {
    dir = vim.fn.stdpath("config") .. '/vendor/harpoon',
    config = function()
      local harpoon = require("harpoon").setup()
      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { desc = desc })
      end

      local ui = require("harpoon.ui")
      map('n', '<leader>mm', ui.toggle_quick_menu)
      map('n', '<leader>ma', require("harpoon.mark").add_file)
      map('n', '<leader>m1', function() ui.nav_file(1) end, "Nav file 1")
      map('n', '<leader>m2', function() ui.nav_file(2) end, "Nav file 2")
      map('n', '<leader>m3', function() ui.nav_file(3) end, "Nav file 3")
      map('n', '<leader>m4', function() ui.nav_file(4) end, "Nav file 4")
    end,
  },
  {
    dir = vim.fn.stdpath("config") .. "/vendor/everforest-nvim",
    version = false,
    lazy = false,
    priority = 1000, -- make sure to load this before all the other start plugins
    -- Optional; default configuration will be used if setup isn't called.
    config = function()
      require("everforest").setup({
        background = 'hard'
        -- Your config here

      })
      vim.cmd([[colorscheme everforest]])
    end,
  },

}
