local wibox = require "wibox"
local dpi = require "beautiful.xresources".apply_dpi
local awful = require "awful"
local beautiful = require "beautiful"
local playerctl = require "plugins.bling.signal.playerctl"
local gears = require "gears"

local iconsdir	= gears.filesystem.get_configuration_dir() .. "assets/materialicons/"

local controller = playerctl.lib {}
local playerwidget = wibox.widget {
	widget = wibox.container.background,
	forced_width = dpi(300),
	bg = beautiful.bg_focus,
	fg = beautiful.fg_normal,
	shape = beautiful.rounded_rect,
	{
		widget = wibox.container.margin,
		margins = dpi(5),
		{
			layout = wibox.layout.fixed.horizontal,
			forced_height = dpi(50),
			spacing = dpi(10),
			{
				widget = wibox.container.background,
				shape = beautiful.rounded_rect,
				bg = beautiful.green,
				fg = beautiful.bg_normal,
				forced_width = dpi(200),
				{
					widget = wibox.container.margin,
					margins = dpi(5),
					{
						layout = wibox.layout.fixed.vertical,
						{
							id = 'title',
							widget = wibox.widget.textbox,
							font = beautiful.font_bold .. " 13",
							align = 'left',
							text = "nothing playing"
						},
						{
							id = 'artist',
							widget = wibox.widget.textbox,
							font = beautiful.font_thin .. " 11",
							align = 'left',
							text = "nothing playing"
						},
					}
				}
			},
			{
				widget = wibox.container.place,
				valign = 'center',
				{
					layout = wibox.layout.fixed.horizontal,
					{
						widget = wibox.widget.imagebox,
						image = gears.color.recolor_image(iconsdir .. "previous.svg", beautiful.fg_normal),
						forced_height = dpi(20)
					},
					{
						id = 'play-pause',
						widget = wibox.widget.imagebox,
						image = gears.color.recolor_image(iconsdir .. "pause.svg", beautiful.fg_normal),
						forced_height = dpi(20)
					},
					{
						widget = wibox.widget.imagebox,
						image = gears.color.recolor_image(iconsdir .. "next.svg", beautiful.fg_normal),
						forced_height = dpi(20)
					},
				}
			},
		}
	}
}
controller:connect_signal("metadata", function (_, title, artist, _, _, _, _)
	playerwidget:get_children_by_id('title')[1]:set_markup_silently(title)
	playerwidget:get_children_by_id('artist')[1]:set_markup_silently(artist)
end)

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
			{
				layout = wibox.layout.fixed.vertical,
				playerwidget
			}
		}
	}
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
