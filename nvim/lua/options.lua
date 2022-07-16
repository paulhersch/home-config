vim.g.sonokai_style = 'maia'
vim.g.sonokai_better_performance = true

local o = vim.opt
o.background = 'dark'
o.clipboard = 'unnamedplus'
o.mouse = 'a'
o.cul = true
o.number = true
o.shiftwidth = 4
o.tabstop = 4
o.expandtab = true
o.termguicolors = true
o.showmode = false

vim.cmd "colorscheme sonokai"
