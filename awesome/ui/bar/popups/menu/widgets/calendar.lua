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
	bg = beautiful.bg_focus_dark,
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
					fg = flag == 'focus' and beautiful.blue or beautiful.fg_dark,
					{
						widget = wibox.container.margin,
						margins = dpi(5),
						{
							widget = wibox.container.place,
							halign = 'center',
							valign = 'center',
							widget
						}
					}
				}
			end
		}
	}
}

return cal
