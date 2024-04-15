local o = vim.opt
local g = vim.g

-- idk why i have to set this but it seems like colors are handled differently if
-- background = 'dark' is not set
o.background = 'dark'
o.clipboard = 'unnamedplus'
o.mouse = 'a'
o.cul = true
o.shiftwidth = 4
o.tabstop = 4
o.expandtab = true
o.termguicolors = true
o.showmode = false
o.linebreak = true
o.fillchars = "vert:┃,horiz:━,stl: ,stlnc: ,fold: ,foldopen:,foldclose:,foldsep: "
o.cmdheight = 1
o.syntax = "off"
o.updatetime = 1000

if g.neovide then
    -- w-0.1 is a hack to get full character height, somehow the font rendering
    -- in neovide makes the glyphs smaller otherwise
    vim.opt.guifont = "Iosevka Comfy Motion Fixed:#e-subpixelantialias:h12:w-0.1"
    g.neovide_padding_top = 5
    g.neovide_padding_left = 5
    g.neovide_padding_bottom = 5
    g.neovide_padding_right = 5
    g.neovide_floating_shadow = false
    g.neovide_refresh_rate = 60
    g.neovide_refresh_rate_idle = 1
    g.neovide_scroll_animation_length = 0.1
    g.neovide_cursor_animation_length = 0.05
    g.neovide_confirm_quit = true
end

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
