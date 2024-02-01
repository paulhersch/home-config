local M = {}

function M.get_colors()
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

return M
