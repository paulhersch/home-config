local beautiful = require "beautiful"
local wibox = require "wibox"
local awful = require "awful"
local gears = require "gears"
local dpi = beautiful.xresources.apply_dpi

local bg_widget = wibox.widget {
	layout = wibox.layout.grid,
	homogeneous   = true,
	spacing       = dpi(20),
	horizontal_expand = true,
	vertical_expand = true,
	forced_num_cols = 8,
	forced_num_rows = 5
}

bg_widget:add_widget_at(wibox.widget {
	image		= beautiful.wallpaper,
	widget		= wibox.widget.imagebox,
	resize		= true,
	scaling_quality	= 'best',
	valign = 'center',
	halign = 'center',
	horizontal_fit_policy = "fit",
	clip_shape = gears.shape.rounded_rect
}, 1, 1, 5, 6)

bg_widget:add_widget_at(wibox.widget {
	widget = wibox.container.background,
	bg = beautiful.bg_normal,
	shape = gears.shape.rounded_rect,
	fg = beautiful.fg_normal,
	{
		widget = wibox.widget.textclock,
		format = "%H:%M",
		valign = "center",
		halign = "center",
		font = beautiful.font_bold .. " 30",
	}
}, 1, 7, 1, 2)




screen.connect_signal("request::wallpaper", function(s)
	s.bg_widget = bg_widget
	s.bg_widget.forced_width = s.geometry.width*0.8
	s.bg_widget.forced_height = s.geometry.height*0.6

	awful.spawn.easy_async_with_shell("fortune", function(stdout, _, _, _)
		s.bg_widget:add_widget_at(wibox.widget {
			widget = wibox.container.background,
			bg = beautiful.bg_normal,
			fg = beautiful.fg_normal,
			shape = gears.shape.rounded_rect,
			{
				widget = wibox.widget.textbox,
				valign = "center",
				halign = "center",
				font = beautiful.font_bold .. " 20",
				text = stdout
			}
		}, 2, 7, 2, 2)
	end)
	awful.wallpaper {
		screen = s,
		widget = {
			{
				widget = wibox.container.place,
				bg_widget
			},
			widget = wibox.container.background,
			bg = beautiful.bg_focus
		}
	}
end)
