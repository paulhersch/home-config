local wibox = require "wibox"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi

local styles = {
	month = {
	},
	normal = {
	},
	focus = {
	},
	monthheader = {
	},
	weekday = {
	}
}

local cal = wibox.widget {
	widget = wibox.container.background,
	bg = beautiful.blue,
	shape = beautiful.theme_shape,
	{
		widget = wibox.container.margin,
		margins = dpi(5),
		{
			widget = wibox.widget.calendar.month,
			date = os.date("*t"),
			flex_height = true,
			font = beautiful.font .. " 10",

			fn_embed = function (widget, flag, _)
				return wibox.widget {
					widget = wibox.container.background,
					shape = beautiful.theme_shape,
					bg = flag == 'focus' and beautiful.bg_focus,
					fg = flag == 'focus' and beautiful.fg_normal or beautiful.bg_normal,
					{
						widget = wibox.container.place,
						halign = 'center',
						valign = 'center',
						widget
					}
				}
			end
		}
	}
}

return cal
