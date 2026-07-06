-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

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

-- Autocompletion
opt.autocomplete = true
opt.completeopt = 'menu,menuone,noselect,popup,nearest'
opt.pumborder = 'rounded'
opt.pummaxwidth = 48
opt.complete = '.^5,t^3,w'
opt.shortmess:prepend('c')
