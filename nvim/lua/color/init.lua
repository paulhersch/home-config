local M, P = {}, {}
local config = require('color.config')
local hl = vim.api.nvim_set_hl

function P.dark()
	local colors = {}
	colors.comment = "#6C6F85"
	colors.background = "#2b2f2f"
	colors.background_dark = "#343737"
    colors.inactive_tabs = "#3b3f3f"
	colors.contrast = "#444747"
	colors.foreground = "#E8EAE3"
	colors.cursorline = "#515757"
	colors.cursor = colors.foreground

    colors.color0 = "#222828"
	colors.color1 = "#cf7767"
	colors.color2 = "#7caf6e"
	colors.color3 = "#cac76b"
	colors.color4 = "#67a0d8"
	colors.color5 = "#b47fc5"
	colors.color6 = "#6cbaba"
	colors.color7 = "#939998"

    colors.color8 = "#3b4244"
	colors.color9 = "#cf7d7d"
	colors.color10 = "#7bc578"
	colors.color11 = "#c8c67a"
	colors.color12 = "#71bae2"
	colors.color13 = "#ce99cf"
	colors.color14 = "#77bbc2"
	colors.color15 = "#9da3a2"

    -- map extra colors used in light theme
    colors.color16 = colors.color8
	colors.color17 = colors.color9
	colors.color18 = colors.color10
	colors.color19 = colors.color11
	colors.color20 = colors.color12
	colors.color21 = colors.color13
	colors.color22 = colors.color14
	colors.color23 = colors.color15

	return colors
end

function P.light()
	local colors = {}
    colors.background       = "#E8EAE3"
    colors.background_dark  = "#DCE0DA"
    colors.inactive_tabs    = "#D6D9D4"
    colors.contrast         = "#CCD0CA"
    colors.foreground       = "#2b2f2f"
    colors.cursorline       = "#515757"
    colors.comment          = "#6C6F85"
    colors.cursor = colors.foreground

    -- dark
    colors.color0 = "#6b6767"
	colors.color1 = "#3f1a1a"
	colors.color2 = "#2c3f1e"
	colors.color3 = "#3a371b"
	colors.color4 = "#072548"
	colors.color5 = "#241f45"
	colors.color6 = "#0c3a3a"
	colors.color7 = "#333938"
    -- medium
	colors.color8 = colors.inactive_tabs
	colors.color9 = "#6f4d4d"
	colors.color10 = "#4b7548"
	colors.color11 = "#88862a"
	colors.color12 = "#316a92"
	colors.color13 = "#9e599f"
	colors.color14 = "#377b82"
	colors.color15 = "#414444"
    -- bright pastel
    colors.color16 =  colors.background_dark
    colors.color17 = "#ECB5B5"
    colors.color18 = "#A2D5B5"
    colors.color19 = "#D5D5AB"
    colors.color20 = "#ABDBE5"
    colors.color21 = "#CBB4CB"
    colors.color22 = "#A8D8D0"
    colors.color23 = "#9292A2"
	return colors
end

function M.setup (opts)
	vim.opt.termguicolors = true
	if opts == nil then
		opts = {
            dark = false
        }
	end

    local colors
    if opts.dark then
     	colors = P.dark()
    else
        colors = P.light()
    end

	for group, properties in pairs(config.get_config(colors)) do
	    hl(0, group, properties)
	end
end

return M
