local wibox = require "wibox"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local gears = require "gears"
local playerctl = require "plugins.bling.signal.playerctl"
local awful = require "awful"

local iconsdir	= gears.filesystem.get_configuration_dir() .. "assets/materialicons/"

local controller = playerctl.lib {
	player = { "spotify" }
}
local function create(base_box)
local playerwidget = wibox.widget {
	widget = wibox.container.background,
	forced_width = dpi(300),
	bg = beautiful.bg_focus_dark,
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
				bg = beautiful.bg_focus,
				fg = beautiful.fg_normal,
				forced_width = dpi(200),
				{
					widget = wibox.container.margin,
					margins = dpi(5),
					{
						layout = wibox.layout.fixed.vertical,
						{
							id = 'title',
							widget = wibox.widget.textbox,
							font = beautiful.font_bold .. " 11",
							align = 'left',
							forced_height = beautiful.get_font_height(beautiful.font_bold .. " 11"),
							text = "nothing playing"
						},
						{
							id = 'artist',
							widget = wibox.widget.textbox,
							font = beautiful.font_thin .. " 9",
							align = 'left',
							forced_height = beautiful.get_font_height(beautiful.font_thin .. " 9"),
							text = "nothing playing"
						},
						{
							widget = wibox.container.place,
							valign = 'bottom',
							fill_vertical = true,
							{
								id = 'seeker',
								widget = wibox.widget.progressbar,
								forced_height = dpi(5),
								forced_width = dpi(180),
								background_color = beautiful.bg_focus,
								color = beautiful.blue,
								bar_shape = gears.shape.rounded_bar,
								shape = gears.shape.rounded_bar,
								max_value = 1,
								value = 0.5
							}
						}
					}
				}
			},
			{
				widget = wibox.container.place,
				valign = 'center',
				{
					layout = wibox.layout.flex.horizontal,
					{
						id = 'bg',
						widget = wibox.container.background,
						shape = beautiful.theme_shape,
						bg = beautiful.bg_focus_dark,
						{
							widget = wibox.container.place,
							halign = 'center',
							valign = 'center',
							{
								widget = wibox.widget.imagebox,
								image = gears.color.recolor_image(iconsdir .. "previous.svg", beautiful.fg_normal),
								buttons	= awful.button({}, 1, function() controller:previous(controller) end),
								forced_height = dpi(20)
							}
						}
					},
					{
						id = 'bg',
						widget = wibox.container.background,
						shape = beautiful.theme_shape,
						bg = beautiful.bg_focus_dark,
						{
							widget = wibox.container.place,
							halign = 'center',
							valign = 'center',
							{
								id = 'play_pause',
								widget = wibox.widget.imagebox,
								image = gears.color.recolor_image(iconsdir .. "pause.svg", beautiful.fg_normal),
								buttons	= awful.button({}, 1, function() controller:play_pause(controller) end),
								forced_height = dpi(20)
							}
						}
					},
					{
						id = 'bg',
						widget = wibox.container.background,
						shape = beautiful.theme_shape,
						bg = beautiful.bg_focus_dark,
						{
							widget = wibox.container.place,
							halign = 'center',
							valign = 'center',
							{
								widget = wibox.widget.imagebox,
								image = gears.color.recolor_image(iconsdir .. "next.svg", beautiful.fg_normal),
								buttons	= awful.button({}, 1, function() controller:next(controller) end),
								forced_height = dpi(20)
							}
						}
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
controller:connect_signal("playback_status", function(_,playing)
	if playing
	then playerwidget:get_children_by_id('play_pause')[1].image = gears.color.recolor_image(iconsdir .. "pause.svg", beautiful.fg_focus)
	else playerwidget:get_children_by_id('play_pause')[1].image = gears.color.recolor_image(iconsdir .. "play.svg", beautiful.fg_focus)
	end
end)
controller:connect_signal("position", function(_, pos, length, _)
	playerwidget:get_children_by_id('seeker')[1].value = pos/length
end)

-- this basically changes the cursor when hovering over the buttons of the widget
--local default_cursor = base_box.cursor
for _,w in ipairs(playerwidget:get_children_by_id('bg')) do
	require("helpers").pointer_on_focus(w, base_box)
	w:connect_signal("mouse::enter", function (self)
		self.bg = beautiful.bg_focus
    --	base_box.cursor = "hand1"
	end)
	w:connect_signal("mouse::leave", function (self)
		self.bg = beautiful.bg_focus_dark
	--	base_box.cursor = default_cursor
	end)
end

return playerwidget
end

return {
	create = create
}
