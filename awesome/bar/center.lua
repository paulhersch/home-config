local wibox = require "wibox"
local dpi = require "beautiful.xresources".apply_dpi
local beautiful = require "beautiful"
local gears = require "gears"

local playerwidget = require "bar.widgets.playerctl"
local calendar = require "bar.widgets.calendar"

local layout = wibox.widget {
    layout        = wibox.layout.grid,
    homogeneous   = true,
    spacing       = dpi(5),
	horizontal_expand = true,
	vertical_expand = true,
	forced_width = dpi(490),
	forced_height = dpi(790),
}

layout:add_widget_at(calendar, 1, 7, 2, 4)
layout:add_widget_at(wibox.widget.textbox("a"), 2, 1, 1, 6)
layout:add_widget_at(wibox.widget.textbox("b"), 3, 1, 7, 10)

local function init(s)
	s.center = wibox {
		height = dpi(800),
		width = dpi(500),
		screen = s,
		ontop = true,
		visible = true,
		x = (s.geometry.width-dpi(500))/2,
		y = beautiful.wibar_height + 4*beautiful.useless_gap,
		bg = beautiful.bg_normal,
		border_width = beautiful.border_width,
		border_color = beautiful.bg_focus,
		shape = beautiful.rounded_rect,
		widget = wibox.widget {
			widget = wibox.container.margin,
			margins = dpi(5),
			layout
		}
	}
	layout:add_widget_at(playerwidget.create(s.center), 1, 1, 1, 6)
end


local function hide(s)
	s.center.visible = false
end
local function show(s)
	s.center.visible = true
end

return {
	init = init,
	hide = hide,
	show = show
}
