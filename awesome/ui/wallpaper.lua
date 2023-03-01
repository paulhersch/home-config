local beautiful = require "beautiful"
local wibox = require "wibox"
local awful = require "awful"
local gears = require "gears"
local dpi = beautiful.xresources.apply_dpi
local naughty = require "naughty"
local helpers = require("helpers")

screen.connect_signal("request::wallpaper", function(s)
	awful.wallpaper {
		screen = s,
		widget = wibox.widget {
			image		= helpers.crop_surface(s.geometry.width/s.geometry.height, gears.surface.load(beautiful.wallpaper)),
			widget		= wibox.widget.imagebox,
			resize		= true,
			scaling_quality	= 'best',
			valign = 'center',
			halign = 'center',
			horizontal_fit_policy = "fit",
		}
	}
end)
