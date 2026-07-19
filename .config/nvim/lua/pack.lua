-- lua/pack.lua
-- Single source of truth for installed plugins. Pin versions here.

vim.pack.add({
-- Fuzzy finding & Telescope
-- Notice: require ripgrep, fd installed
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  {
    src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
    build = "make"
  },

-- LSP core component from neovim 0.11+
  { src = "https://github.com/neovim/nvim-lspconfig" },
  -- for advanced Autocompletion
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('1.*') },

-- Git 
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/sindrets/diffview.nvim" },

-- Util
  { src = "https://github.com/christoomey/vim-tmux-navigator" },

-- UI Components
  -- Navigation
  { src = "https://github.com/nvim-tree/nvim-tree.lua" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  -- Color Scheme
  { src = "https://github.com/rebelot/kanagawa.nvim" },

-- Debug
-- nvim-dap core（debug protocol)
  {
    src = 'https://github.com/mfussenegger/nvim-dap.git',
    name = 'nvim-dap',
  },
  -- nvim-dap-ui（debug UI)
  {
    src = 'https://github.com/rcarriga/nvim-dap-ui.git',
    name = 'nvim-dap-ui',
  },
  {
    src = 'https://github.com/nvim-neotest/nvim-nio.git',
  },
  -- Virtual text（optional）
  {
    src = 'https://github.com/theHamsta/nvim-dap-virtual-text.git',
    name = 'nvim-dap-virtual-text',
  },

  -- Core R functionality
  { src = "https://github.com/R-nvim/R.nvim" },
})
