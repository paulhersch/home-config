local wibox = require "wibox"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local Gio = require "lgi".Gio
local gears = require "gears"

--might sip some RAM but better runtime performance
LAUNCHER_CACHED_GIO_ENTRIES = Gio.AppInfo.get_all()

local entry_template = {
	id = "bg",
	widget = wibox.container.background,
	bg = beautiful.bg_focus_dark,
	{
		widget = wibox.container.margin,
		margins = dpi(5),
		{
			layout = wibox.layout.align.horizontal,
			{
				widget = wibox.container.margin,
				margins = dpi(5),
				{
					id = "logo",
					widget = wibox.widget.imagebox,
					shape = beautiful.theme_shape
				}
			},
			{
				id = "appname",
				widget = wibox.widget.textbox
			},
			wibox.widget.base.make_widget()
		}
	}
}

local widget_template = {
	layout = wibox.layout.align.vertical,
	expand = "inside",
	{
	},
	{
		id = 'grid',
		layout = wibox.layout.grid,
		homogeneous = true,
		forced_num_cols = 1,
		forced_num_rows = 9,
		expand = true,
		vertical_spacing = dpi(3),
	},
	{
		layout = wibox.layout.fixed.horizontal,
		forced_height = beautiful.get_font_height(beautiful.font .. " 12"),
		{
			widget = wibox.widget.imagebox,
			image = gears.color.recolor_image(gears.filesystem.get_configuration_dir() .. "/assets/materialicons/search.svg", beautiful.fg_normal),
			forced_width = beautiful.get_font_height(beautiful.font .. " 12"),
		},
		{
			widget = wibox.container.margin,
			left = dpi(5),
			right = dpi(5),
			{
				widget = wibox.container.place,
				valign = 'center',
				halign = 'left',
				fill_horizontal = true,
				{
					id = 'prompttext',
					font = beautiful.font .. " 12",
					widget = wibox.widget.textbox
				}
			}
		}
	}
}
