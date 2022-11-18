local beautiful = require "beautiful"
local wibox = require "wibox"
local awful = require "awful"
local gears = require "gears"
local dpi = beautiful.xresources.apply_dpi
local naughty = require "naughty"

screen.connect_signal("request::wallpaper", function(s)
	awful.wallpaper {
		screen = s,
		widget = wibox.widget {
			image		= beautiful.wallpaper,
			widget		= wibox.widget.imagebox,
			resize		= true,
			scaling_quality	= 'best',
			valign = 'center',
			halign = 'center',
			horizontal_fit_policy = "fit",
			clip_shape = gears.shape.rounded_rect
		}
	}
end)
