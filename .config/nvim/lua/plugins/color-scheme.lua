-- 1. True-color support is required for Kanagawa
vim.opt.termguicolors = true

-- local bg_search = "#0A64AC"

require('kanagawa').setup({
  compile = false,
  theme = "wave",
  terminalColors = true,

  undercurl = true,
  commentStyle = { italic = true },
--  functionStyle = { bold = true },

  background = {
    dark = "wave",
    light = "lotus"
  },
})

vim.cmd("colorscheme kanagawa")
