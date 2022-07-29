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
o.cmdheight = 0

o.spell = true
o.spelllang = { 'de_de' }

require("everblush").setup({
    nvim_tree = { contrast = false }
})

local evblushcols = require("everblush.core").get_colors()

vim.highlight.create('VertSplit', {guibg=evblushcols.background, guifg=evblushcols.color0}) --visually remove splits
vim.highlight.create('CursorLine', {guibg=evblushcols.background})
vim.highlight.create('CursorLineNr', {guifg=evblushcols.foreground})
vim.highlight.create('Comment', {gui='italic'})
vim.highlight.create('TSComment', {gui='italic'})
vim.highlight.create('TSKeyword', {gui='italic'})
