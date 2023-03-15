local M = {}

function M.get_colors()
	local colors = {}
	colors.comment = "#6C6F85"
	colors.background = "#DADCD5"
    colors.inactive_tabs = "#BCC0BA"
	colors.background_dark = "#CCD0CA"
	colors.contrast = "#C5C5C2"
	colors.foreground = "#2b2f2f"
	colors.cursorline = "#515757"
	colors.cursor = colors.foreground
	
    colors.color0 = colors.background_dark
	colors.color1 = "#5f4747"
	colors.color2 = "#3c7f2e"
	colors.color3 = "#9a972b"
	colors.color4 = "#275078"
	colors.color5 = "#744f85"
	colors.color6 = "#2c7a7a"
	colors.color7 = "#939998"
	colors.color8 = "#4C4F69"
	colors.color9 = "#6f3d3d"
	colors.color10 = "#4b7548"
	colors.color11 = "#88862a"
	colors.color12 = "#316a92"
	colors.color13 = "#9e599f"
	colors.color14 = "#377b82"
	colors.color15 = "#313434"
	return colors
end

return M
