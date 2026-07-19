local keymap = vim.keymap

-- Telescope
local builtin = require("telescope.builtin")

-- Custom helper to pass arguments cleanly
local map = function(mode, lhs, rhs, desc)
  keymap.set(mode, lhs, rhs, { silent = true, desc = "Telescope: " .. desc })
end

-- Most widely adopted mappings
map("n", "<leader>ff", builtin.find_files, "Find Files")
map("n", "<leader>fg", builtin.live_grep, "Live Grep (Text)")
map("n", "<leader>fb", builtin.buffers, "Find Open Buffers")
map("n", "<leader>fh", builtin.help_tags, "Find Help Mappings")
map("n", "<leader>fr", builtin.oldfiles, "Find Recent Files")

-- Coding
-- map("n", "<leader>gd", builtin.lsp_definition, "[G]to definition")
-- map("n", "<leader>gr", builtin.lsp_references, "[G]to references")
-- map("n", "<leader>gi", builtin.lsp_implementation, "[G]to implementation")
--
--
-- DiffView (moved to <leader>g: used to collide with DAP on <leader>dc/do)

keymap.set("n", "<leader>go", "<cmd>DiffviewOpen<CR>", { desc = "Open Diffview (Working Tree)" })
keymap.set("n", "<leader>gl", "<cmd>DiffviewOpen HEAD~1<CR>", { desc = "Diffview (Last Commit)" })
keymap.set("n", "<leader>gc", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" })

-- File History
keymap.set("n", "<leader>gf", "<cmd>DiffviewFileHistory %<CR>", { desc = "Diffview History (Current File)" })
keymap.set("n", "<leader>gF", "<cmd>DiffviewFileHistory<CR>", { desc = "Diffview History (Whole Repo)" })

-- Debug (通用)
local dap = require("dap")
local dapui = require("dapui")
keymap.set('n', '<leader>dc', dap.continue,          { desc = 'Debug: Continue' })
keymap.set('n', '<leader>dn', dap.step_over,         { desc = 'Debug: Step Over (Next)' })
keymap.set('n', '<leader>di', dap.step_into,         { desc = 'Debug: Step Into' })
keymap.set('n', '<leader>do', dap.step_out,          { desc = 'Debug: Step Out' })
keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
keymap.set('n', '<leader>dB', function()
  dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, { desc = 'Debug: Conditional Breakpoint' })
keymap.set('n', '<leader>dr', dap.restart,           { desc = 'Debug: Restart' })
keymap.set('n', '<leader>dq', dap.terminate,         { desc = 'Debug: Quit' })
keymap.set('n', '<leader>du', dapui.toggle,          { desc = 'DAP: Toggle UI' })
keymap.set('n', '<leader>dR', dap.repl.toggle,       { desc = 'DAP: Toggle REPL' })
keymap.set('n', '<leader>dL', '<cmd>DapShowLog<CR>', { desc = 'DAP: Show Log' })

-------------------------------------------------------------------------------
-- Fold/Unfold
-------------------------------------------------------------------------------
-- Basic fold toggling
keymap.set("n", "za", "za", { desc = "Toggle fold under cursor" })
keymap.set("n", "zA", "zA", { desc = "Toggle all folds recursively" })

-- Open/close operations
keymap.set("n", "zc", "zc", { desc = "Close fold" })
keymap.set("n", "zo", "zo", { desc = "Open fold" })
keymap.set("n", "zC", "zC", { desc = "Close all folds recursively" })
keymap.set("n", "zO", "zO", { desc = "Open all folds recursively" })

-- File-level operations
keymap.set("n", "zR", "zR", { desc = "Open all folds in file" })
keymap.set("n", "zM", "zM", { desc = "Close all folds in file" })

-- Smart toggle with <Tab> (popular alternative)
keymap.set("n", "<Tab>", "za", { desc = "Toggle fold" })

-- Move between folds
keymap.set("n", "]z", "]z", { desc = "Move to next fold" })
keymap.set("n", "[z", "[z", { desc = "Move to previous fold" })
