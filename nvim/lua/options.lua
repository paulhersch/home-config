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
o.linebreak = true
o.fillchars.horiz = '━'
o.fillchars.stl = ' '
o.cmdheight = 0
o.updatetime = 1000

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
--remove diagnostics at end of line
vim.diagnostic.config({
	virtual_text = true
})

local alternative_signs = {
    Error = ' ',
    Warn = ' ',
    Hint = ' ',
    Info = ' '
}
for type, icon in pairs(alternative_signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.fn.sign_define("DapBreakpoint", { text = '●', texthl='DapBreakpointSymbol'})
