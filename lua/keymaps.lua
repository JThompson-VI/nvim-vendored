local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

vim.g.mapleader = " "
vim.g.maplocalleader = ' '

--mapping to run curent python script
-- map('n', '<leader>rp', '<cmd>!python3 %<cr>')

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
-- normal mode
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

map('n', '<leader>q', ':q<cr>')
map('n', '<leader>w', ':w<cr>')
map('n', '<leader>c', ':Bdelete<cr>')  -- unload current buffer with vim-bbye
map('n', '<leader>C', ':Bwipeout<cr>') -- unload current buffer and remove its jumplist entries

map('n', '<leader>h', ':nohl<cr>')

-- Move around splits using Ctrl + {h,j,k,l}
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

-- Resize with arrows
map("n", "<C-Up>", ":resize -2<CR>")
map("n", "<C-Down>", ":resize +2<CR>")
map("n", "<C-Left>", ":vertical resize -2<CR>")
map("n", "<C-Right>", ":vertical resize +2<CR>")

-- move between buffers
map('n', '<S-l>', ':bnext<cr>')
map('n', '<S-h>', ':bprevious<cr>')

-- misc mappings
map('n', 'Q', '!!sh<CR>')
map('n', 'gvd', '<CMD>vs<CR>gd')
map('n', '<leader>y', '"+y')
map('v', '<leader>y', '"+y')
map('n', '<leader>d', '"_d')
map('n', 'J', 'mzJ`z')
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')
map('n', '<leader>Y', '"+y$"')
-- map('n', 'n', 'nzzzv')
-- map('n', 'N', 'Nzzzv')

-- -- insert mode
map('i', 'jk', '<Esc>')

-- -- visual mode
map('v', 'p', '"_dP') -- don't copy pasted over text in vis mode
map('v', 'J', ":m '>+1<CR>gv=gv")
map('v', 'K', ":m '<-2<CR>gv=gv")

map('n', 'zC', 'zM') -- close all folds
map('n', 'zO', 'zR') -- open all folds
map('n', '<leader>rp', '<cmd>!python3.13 %<cr>')

-- FTerm
vim.keymap.set('n', '<C-Y>', '<CMD>lua require("FTerm").toggle()<CR>')
vim.keymap.set('t', '<C-Y>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')

map('n', '<leader>lf', ':!eslint --fix %<CR>')

--[[ example
db.oneOrNone(/* sql */`
select * from foo_bar where 
person_id = :person_id
and start_date = :startDate::DATE
`)
 ]]
