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
--o.fillchars.horiz = '━' --using the bar anyways
o.cmdheight = 0

o.spell = true
o.spelllang = { 'de_de' }

require("everblush").setup({
    nvim_tree = { contrast = false }
})

local evblushcols = require("everblush.core").get_colors()

vim.api.nvim_set_hl(0, 'NvimTreeOpenedFolderName', { fg = evblushcols.color4 })
vim.api.nvim_set_hl(0, 'NvimTreeEmptyFolderName', { fg = evblushcols.comment })
vim.api.nvim_set_hl(0, 'NvimTreeNormal', { fg = evblushcols.color7 })

vim.api.nvim_set_hl(0, 'NvimTreeOpenedFile', { fg = evblushcols.foreground, italic=true })

vim.api.nvim_set_hl(0, 'VertSplit', {bg=evblushcols.background, fg=evblushcols.color0}) --visually remove splits
vim.api.nvim_set_hl(0, 'CursorLine', {bg=evblushcols.background})
vim.api.nvim_set_hl(0, 'CursorLineNr', {fg=evblushcols.foreground})
vim.api.nvim_set_hl(0, 'Comment', {italic=true, fg = evblushcols.comment})
vim.api.nvim_set_hl(0, 'TSComment', {italic=true, fg = evblushcols.comment})
vim.api.nvim_set_hl(0, 'TSKeyword', {fg = evblushcols.color5 , italic=true}) --manual override
