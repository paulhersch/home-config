local beautiful = require "beautiful"
local wibox = require "wibox"
local awful = require "awful"
local gears = require "gears"

screen.connect_signal("request::wallpaper", function(s)
	awful.wallpaper {
		screen = s,
		widget = wibox.widget {
			image = gears.surface.crop_surface {
                surface = gears.surface.load(beautiful.wallpaper),
                ratio = s.geometry.width/s.geometry.height,
            },
			widget		= wibox.widget.imagebox,
			resize		= true,
			scaling_quality	= 'best',
			horizontal_fit_policy = "fit",
		}
	}
end)
