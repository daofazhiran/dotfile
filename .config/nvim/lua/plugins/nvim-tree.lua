-- lua/plugins/nvim-tree.lua

-- Disable netrw early (required, before plugin setup)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Enable 24-bit colour for proper icon/highlight rendering
vim.opt.termguicolors = true

require("nvim-web-devicons").setup({})

require("nvim-tree").setup({
  sort = { sorter = "case_sensitive" },
  view = {
    width = 35,
    side = "left",
    preserve_window_proportions = true,
  },
  renderer = {
    group_empty = true,
    highlight_git = true,
    indent_markers = { enable = true },
    icons = {
      show = { file = true, folder = true, folder_arrow = true, git = true },
    },
  },
  filters = {
    dotfiles = false,
    git_ignored = true, -- show .gitignored files; flip to true to hide
    custom = { "^.git$", ".DS_Store", "__pycache__", ".dart_tool", "target" },
  },
  git = { enable = true, ignore = false },
  diagnostics = {
    enable = true, -- LSP diagnostics in the tree (useful for your polyglot setup)
    show_on_dirs = true,
    icons = { hint = " ", info = " ", warning = " ", error = " " },
  },
  actions = {
    open_file = {
      quit_on_open = false,
      resize_window = true,
    },
  },
  update_focused_file = {
    enable = true, -- follow the file in the active buffer
    update_root = false,
  },
})

-- Keymaps
local map = vim.keymap.set
map("n", "<leader>ee", "<cmd>NvimTreeToggle<cr>", { desc = "[F]ile exploer: Toggle file tree" })
map("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<cr>", { desc = "[F]ile exploer: Toggle current file" })
map("n", "<leader>et", "<cmd>NvimTreeFocus<cr>", { desc = "[F]ile exploer: Focus on tree" })
map("n", "<leader>er", "<cmd>NvimTreeRefresh<cr>", { desc = "[F]ile exploer: Refresh file tree" })
