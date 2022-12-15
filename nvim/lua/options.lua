local o = vim.opt

o.background = 'dark'
o.clipboard = 'unnamedplus'
o.mouse = 'a'
o.cul = true
o.number = true
o.shiftwidth = 4
o.tabstop = 4
o.termguicolors = true
o.showmode = false
o.fillchars.vert = '┃'
o.linebreak = true
o.fillchars.horiz = '━'
o.cmdheight = 0

local g = vim.g
if g.neovide then
	vim.cmd [[set guifont=CaskaydiaCove\ Nerd\ Font\ Mono:h7]]
	g.neovide_refresh_rate = 60
	g.neovide_refresh_rate_idle = 1
	g.neovide_scroll_animation_length = 0.1
	g.neovide_cursor_animation_length = 0.05
	g.neovide_confirm_quit=true
end

require("azul").setup {}
