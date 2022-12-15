local wibox = require "wibox"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi

local template = {
	
}

local function init(s)
	local w, h = dpi(400), dpi(600)

	s.launcher = wibox {
		x = s.geometry.x + 2*beautiful.useless_gap,
		y = s.geometry.y + beautiful.wibar_height + 2*beautiful.useless_gap,
		width = w,
		height = h,
		screen = s
	}

	function s.box:show()
	end
	function s.box:hide()
	end
end

local function show(s)
	s.box:hide()
end

local function hide(s)
	s.box:show()
end

return {
	init = init,
	show = show,
	hide = hide
}
