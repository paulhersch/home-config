local wibox = require "wibox"
local dpi = require "beautiful.xresources".apply_dpi
local beautiful = require "beautiful"

local playerwidget = require "bar.widgets.playerctl"
local calendar = require "bar.widgets.calendar"
local layouts = require "bar.widgets.layout"
local powerbuttons = require "bar.widgets.powerbuttons"
local notifications = require "bar.widgets.not_center"

local layout = wibox.widget {
    layout        = wibox.layout.grid,
    homogeneous   = true,
    spacing       = dpi(5),
	horizontal_expand = true,
	vertical_expand = true,
	forced_width = dpi(490),
	forced_height = dpi(790),
	forced_num_cols = 5,
	forced_num_rows = 8
}

layout:add_widget_at(calendar, 2, 3, 3, 3)
layout:add_widget_at(layouts, 2, 1, 1, 2)
layout:add_widget_at(powerbuttons.widget, 1, 4, 1, 2)
layout:add_widget_at(notifications, 5, 1, 5, 5)

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
	layout:add_widget_at(playerwidget.create(s.center), 1, 1, 1, 3)
end


local function hide(s)
	s.center.visible = false
    powerbuttons.hide()
end
local function show(s)
	s.center.visible = true
end

return {
	init = init,
	hide = hide,
	show = show
}
