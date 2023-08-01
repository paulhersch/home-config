local o = vim.opt
local g = vim.g

o.background = 'dark'
o.clipboard = 'unnamedplus'
o.mouse = 'a'
o.cul = true
o.shiftwidth = 4
o.tabstop = 4
o.expandtab = true
o.termguicolors = true
o.showmode = false
o.fillchars.vert = '┃'
o.linebreak = true
o.fillchars.horiz = '━'
o.fillchars.stl = ' '
o.fillchars.stlnc = ' '
o.fillchars.fold = '━'
o.fillchars.foldopen = ''
o.fillchars.foldclose = ''
o.cmdheight = 0
o.updatetime = 1000

o.foldmethod = "expr"
o.foldexpr = "nvim_treesitter#foldexpr()"
o.foldenable = false

g.vsnip_snippet_dir = os.getenv("HOME") .. "/.config/nvim/snips"

if g.neovide then
	o.guifont = "Iosevka Comfy Motion:h10,Symbols Nerd Font:h10"
	g.neovide_refresh_rate = 60
	g.neovide_refresh_rate_idle = 1
	g.neovide_scroll_animation_length = 0.1
	g.neovide_cursor_animation_length = 0.05
	g.neovide_confirm_quit=true
end

--remove diagnostics at end of line
vim.diagnostic.config({
	virtual_text = false
})

local alternative_signs = {
    Error = '',
    Warn = '',
    Hint = '',
    Info = ''
}

for type, icon in pairs(alternative_signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
