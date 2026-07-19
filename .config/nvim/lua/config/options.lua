-- Leader key
-- mapleader = " "（全局编辑前缀，所有 R / 通用键位都挂在空格后）
-- maplocalleader 保持默认 \ （R.nvim 的 60+ 键位用 \ 前缀；改成空格会
--   抢占 DAP / diffview 的 <Space>db / <Space>do 等。详见 dao.of.nvim/01_r.qmd
--   §快捷键全览 的"为什么不保留 <Space> 做 LocalLeader"callout）
vim.g.mapleader = " "

vim.g.have_nerd_font = true

local opt = vim.opt

-- Line setting
opt.number = true
opt.relativenumber = true

-- Cursor line
opt.cursorline = true
opt.scrolloff = 10
opt.sidescrolloff = 8

-- Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

-- Case-insentivie searching
opt.ignorecase = true
opt.smartcase = true

-- Visual settings
opt.showmode = false

opt.termguicolors = true

-- Clipboard
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-------------------------------------------------------------------------------
-- Autocompletion
-------------------------------------------------------------------------------
-- Native auto-popup is disabled: blink.cmp is the completion UI (see plugins/blink-cmp.lua)
opt.autocomplete = false
opt.completeopt = 'menu,menuone,noselect,popup,nearest'
opt.pumborder = 'rounded'
opt.pummaxwidth = 48
opt.complete = '.^5,t^3,w'
opt.shortmess:prepend('c')

-------------------------------------------------------------------------------
-- Fold/Unfold
-------------------------------------------------------------------------------
-- 1. Enable Treesitter folding
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- 2. Use the modern built-in foldtext (Neovim 0.10+)
opt.foldtext = "v:lua.vim.treesitter.foldtext()"

-- 3. Visual settings
opt.foldcolumn = "auto:9" -- Shows a dynamic fold column (0 to 9 chars wide)
opt.foldlevel = 99        -- Start with all folds open
opt.foldlevelstart = 99   -- Start with all folds open when opening a file
opt.foldenable = true     -- Enable folding

-- 4. Optional: Fill characters for a cleaner look
opt.fillchars = {
  fold = " ",
  foldopen = "", -- Requires a Nerd Font
  foldclose = "",
  foldsep = " ",
}
