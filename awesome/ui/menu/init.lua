local wibox = require "wibox"
local dpi = require "beautiful.xresources".apply_dpi
local beautiful = require "beautiful"

local rubato = require "plugins.rubato"

--local playerwidget = require "ui.menu.widgets.playerctl"
local playerwidget = require "ui.menu.widgets.mpd"

local calendar = require "ui.menu.widgets.calendar"
local layouts = require "ui.menu.widgets.layout"
local powerbuttons = require "ui.menu.widgets.powerbuttons"
--ocal notifications = require "bar.widgets.not_center"
local grindtimer = require "ui.menu.widgets.grinder"

local layout = wibox.widget {
    layout        = wibox.layout.grid,
    homogeneous   = true,
    spacing       = dpi(5),
	horizontal_expand = true,
	vertical_expand = true,
	forced_width = dpi(490),
	forced_height = dpi(790),
	forced_num_cols = 5,
	forced_num_rows = 4
}

layout:add_widget_at(calendar, 2, 3, 3, 3)
layout:add_widget_at(layouts, 2, 1, 1, 2)
layout:add_widget_at(powerbuttons.widget, 1, 4, 1, 2)
layout:add_widget_at(grindtimer,3,1,2,2)
--layout:add_widget_at(notifications, 5, 1, 5, 5)

local function init(s)
	s.menu = wibox {
		height = dpi(400),
		width = dpi(500),
		screen = s,
		ontop = true,
		visible = false,
		x = s.geometry.x + (s.geometry.width-dpi(500))/2,
		y = beautiful.wibar_height + 2*beautiful.useless_gap,
		bg = beautiful.bg_normal,
--		border_width = beautiful.border_width,
--		border_color = beautiful.bg_focus,
		shape = beautiful.theme_shape,
		widget = wibox.widget {
			widget = wibox.container.margin,
			margins = dpi(5),
			layout
		}
	}
	layout:add_widget_at(playerwidget.create(s.center), 1, 1, 1, 3)
    --[[s.menu.flyin = rubato.timed {
        rate = 60,
        duration = 0.3,
        intro = 0.1,
        outro = 0.1,
        pos = 1,
        easing = rubato.easing.linear,
        subscribed = function (pos)
            s.menu.visible = pos < 1
            s.menu.y = beautiful.wibar_height + 2*beautiful.useless_gap - (dpi(400)*pos)
        end
    }]]
    function s.menu:show()
        self.visible = true
        --s.menu.flyin.target = 0
    end
    function s.menu:hide()
        self.visible = false
        --s.menu.flyin.target = 1
    end
end


local function hide(s)
	s.menu:hide()
    powerbuttons.hide()
end
local function show(s)
	s.menu:show()
end

return {
	init = init,
	hide = hide,
	show = show
}
