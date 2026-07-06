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
-- DiffView

keymap.set("n", "<leader>do", "<cmd>DiffviewOpen<CR>", { desc = "Open Diffview (Working Tree)" })
keymap.set("n", "<leader>dl", "<cmd>DiffviewOpen HEAD~1<CR>", { desc = "Diffview (Last Commit)" })
keymap.set("n", "<leader>dc", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" })

-- File History
keymap.set("n", "<leader>df", "<cmd>DiffviewFileHistory %<CR>", { desc = "Diffview History (Current File)" })
keymap.set("n", "<leader>dF", "<cmd>DiffviewFileHistory<CR>", { desc = "Diffview History (Whole Repo)" })

-- Debug
local dap = require("dap")
keymap.set('n', '<leader>dc', dap.continue, { desc = 'Debug: Continue' })
keymap.set('n', '<leader>dn', dap.step_over, { desc = 'Debug: Step Over (Next)' })
keymap.set('n', '<leader>di', dap.step_into, { desc = 'Debug: Step Into' })
keymap.set('n', '<leader>do', dap.step_out, { desc = 'Debug: Step Out' })
keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
keymap.set('n', '<leader>dB', function()
  dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, { desc = 'Debug: Conditional Breakpoint' })
keymap.set('n', '<leader>dr', dap.restart, { desc = 'Debug: Restart' })
keymap.set('n', '<leader>dq', dap.close, { desc = 'Debug: Quit' })

-- keymap.set("n", "<Leader>dr", dap.repl.open, { desc = "Open REPL" })
-- 手动开关 UI
local dapui = require("dapui")
keymap.set("n", "<Leader>du", dapui.toggle, { desc = "DAP: Toggle UI" })

