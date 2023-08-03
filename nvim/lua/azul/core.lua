local M = {}

function M.get_colors()
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

return M
