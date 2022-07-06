local wibox	= require "wibox"
local awful	= require "awful"
local beautiful = require "beautiful"
local gears	= require "gears"

local dpi	= beautiful.xresources.apply_dpi

local lib	= require "plugins.bling.signal.playerctl"
local playerctl	= lib.lib {
	ignore = { "firefox", "librewolf", "chromium" },
	player = { "spotify", "spotify-qt", "spotifyd", "%any" }
}

local iconsdir	= gears.filesystem.get_configuration_dir() .. "assets/materialicons/"

local player = wibox.widget {
		{
			{
				{
					id		= 'cover',
					widget		= wibox.widget.imagebox,
					image		= beautiful.awesome_icon,
					resize		= true,
--[[					clip_shape	= function(cr,w,h)
						if w > h then
							return gears.shape.rounded_rect(cr,h,h)
						else
							return gears.shape.rounded_rect(cr,w,w)
						end
					end]]
					clip_shape	= gears.shape.rounded_rect
				},
				widget	= wibox.container.place,
				halign	= 'left',
				valign	= 'center',
				fill_vertical = true,
				fill_horizontal = true
			},
			widget	= wibox.container.background,
			bg	= beautiful.bg_focus
		},
		{
			{
					{
						widget	= wibox.widget.imagebox,
						image	= gears.color.recolor_image(iconsdir .. "previous.svg", beautiful.fg_focus),
						buttons	= awful.button({}, 1, function() playerctl:previous(playerctl) end),
						valign	= 'center',
						halign	= 'center',
						resize	= true,
					},
					{
						id	= 'play_pause',
						widget	= wibox.widget.imagebox,
						image	= gears.color.recolor_image(iconsdir .. "play.svg", beautiful.fg_focus),
						buttons	= awful.button({}, 1, function() playerctl:play_pause(playerctl) end),
						valign	= 'center',
						halign	= 'center',
						resize	= true,
					},
					{
						widget	= wibox.widget.imagebox,
						image	= gears.color.recolor_image(iconsdir .. "next.svg", beautiful.fg_focus),
						buttons	= awful.button({}, 1, function() playerctl:next(playerctl) end),
						halign	= 'center',
						valign	= 'center',
						resize	= true,
					},
					layout	= wibox.layout.flex.vertical,
			},
			widget	= wibox.container.place,
			halign	= 'right',
			valign	= 'center',
		},
		layout	= wibox.layout.stack,
--		spacing	= beautiful.menu_item_spacing/2,
}

playerctl:connect_signal("metadata", function(_, _, _, album_path)
	player:get_children_by_id('cover')[1]:set_image(gears.surface.load_uncached(album_path))
end)
playerctl:connect_signal("playback_status", function(_, playing)
	if playing
	then player:get_children_by_id('play_pause')[1].image = gears.color.recolor_image(iconsdir .. "pause.svg", beautiful.fg_focus)
	else player:get_children_by_id('play_pause')[1].image = gears.color.recolor_image(iconsdir .. "play.svg", beautiful.fg_focus)
	end
end)

return player
