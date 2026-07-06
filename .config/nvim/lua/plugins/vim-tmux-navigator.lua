vim.g.tmux_navigator_no_mappings = 1

local map = vim.keymap.set
local opts = { silent = true }

map("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", opts)
map("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", opts)
map("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", opts)
map("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", opts)
map("n", "<C-\\>", "<cmd>TmuxNavigatePrevious<CR>", opts)
