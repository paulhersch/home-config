local wibox	= require "wibox"
local gears	= require "gears"
local awful	= require "awful"
local beautiful	= require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local rubato	= require "plugins.rubato"

local iconsdir	= gears.filesystem.get_configuration_dir() .. "assets/materialicons/"

-- main widget declaration {{{
local audiobox = wibox.widget {
	widget = wibox.container.background,
	shape = beautiful.theme_shape,
--	bg = beautiful.bg_focus,
	{
		widget = wibox.container.margin,
		margins = dpi(5),
		{
			layout = wibox.layout.fixed.vertical,
			spacing = dpi(10),
			{
				widget = wibox.container.rotate,
				direction = 'east',
				forced_height = dpi(180),
				{
					id = 'slider',
					widget = wibox.widget.slider,
					maximum = 100,
					minimum = 0,
					value = 50,
					handle_shape = gears.shape.circle,
					handle_width = dpi(15),
					handle_border_width = dpi(5),
					bar_shape = gears.shape.rounded_bar,
					bar_height = dpi(5),

					handle_border_color = beautiful.bg_normal,
					bar_color = beautiful.bg_focus,
					handle_color = beautiful.yellow,
					bar_active_color = beautiful.yellow
				}
			},
			{
				widget = wibox.container.place,
				halign = 'center',
				{
					widget = wibox.widget.imagebox,
					resize = true,
					forced_width = dpi(20),
					forced_height = dpi(20),
					image = gears.color.recolor_image(iconsdir .. "volume_up.svg", beautiful.fg_normal)
				}
			}
		}
	}
}

-- Update function for the widget {{{
local function update_widget ()
	awful.spawn.easy_async("pamixer --get-volume --get-mute", function (stdout)
		local t	= {}
		for str in string.gmatch(stdout, "([^".. "%s".."]+)") do
			table.insert(t, str)
		end
		if t[1] == "false"
			then
				if tonumber(t[2]) < 50
					then
						audiobox:get_children_by_id('symbol')[1].image = gears.color.recolor_image(iconsdir .. "volume_down.svg", beautiful.fg_focus)
					else
						audiobox:get_children_by_id('symbol')[1].image = gears.color.recolor_image(iconsdir .. "volume_up.svg", beautiful.fg_focus)
				end
			else
				audiobox:get_children_by_id('symbol')[1].image = gears.color.recolor_image(iconsdir .. "volume_off.svg", beautiful.fg_focus)
		end
--		anim_volchange.target = t[2]
	end)
end
--}}}

-- enable scroll to change volume {{{
--[[audiobox:connect_signal("button::press", function (w,lx,ly,button)
	if button == 4 then awful.spawn("pamixer -i 5") 
		else if button == 5 then awful.spawn("pamixer -d 5")
			else if button == 3 then awful.spawn("pamixer -t") end
		end
	end
	update_widget()
end)]]
--}}}

--initial update
--update_widget()

return {
	widget	= audiobox,
	update	= update_widget
}
