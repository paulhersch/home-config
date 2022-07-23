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
o.fillchars.vert = '┃'
o.fillchars.horiz = '━'

require("everblush").setup({
    nvim_tree = { contrast = false }
})

local evblushcols = require("everblush.core").get_colors()

vim.highlight.create('VertSplit', {guibg=evblushcols.background, guifg=evblushcols.color0}) --visually remove splits
vim.cmd 'highlight TSComment gui=italic'
vim.cmd 'highlight TSKeyword gui=italic'
vim.cmd 'highlight Comment gui=italic'
