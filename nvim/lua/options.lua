local o = vim.opt
local g = vim.g

o.background = 'light'
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
o.cmdheight = 0
o.laststatus = 3
o.syntax = "off"
o.title = true

if g.neovide then
    -- w-0.1 is a hack to get full character height, somehow the font rendering
    -- in neovide makes the glyphs smaller otherwise
    vim.opt.guifont = "Iosevka Comfy Motion Fixed,Symbols Nerd Font:#e-subpixelantialias:h12:w-0.1"
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

local diagnostic_signs = { '', '', '', '' }
vim.diagnostic.config {
    signs = {
        text = { '', '', '', '' }
    },
    virtual_text = false,
    underline = false,
    float = {
        header = "",
        border = "solid",
        scope = "cursor",
        format = function(diagnostic)
            return string.format("%s  %s", diagnostic_signs[diagnostic.severity], diagnostic.message)
        end,
        prefix = "",
        suffix = function(diagnostic, _, _)
            return string.format("\t(%s)", diagnostic.code), "DiagnosticCode"
        end
    }
}
