local wibox	= require "wibox"
local gears	= require "gears"
local awful	= require "awful"
local beautiful	= require "beautiful"

local rubato	= require "plugins.rubato"

local iconsdir	= gears.filesystem.get_configuration_dir() .. "assets/materialicons/"

-- main widget declaration {{{
local audiobox = wibox.widget {
--	{
		{
			id	= 'symbol',
			widget	= wibox.widget.imagebox,
			image	= gears.color.recolor_image(iconsdir .. "volume_up.svg", beautiful.fg_focus),
			resize	= true,
		},
		widget	= wibox.container.margin,
		margins = beautiful.menu_item_spacing/2,
		valign	= 'center',
		halign	= 'center',
--[[	},
	id		= 'arc',
	widget		= wibox.container.arcchart,
	colors		= { beautiful.fg_primary },
	min_value	= 0,
	max_value	= 100,
	thickness	= 3,
	rounded_edge	= true,
	value		= 100,
	start_angle	= math.pi/2,]]
}
--}}}

-- volume change animation {{{
--[[local anim_volchange = rubato.timed {
	intro		= 0.04,
	outro		= 0.06,
	duration	= 0.1,
	rate		= 60,
	easing		= rubato.quadratic,
	subscribed	= function(pos)
		audiobox:get_children_by_id('arc')[1].value = pos
	end
}]]
--}}}

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
audiobox:connect_signal("button::press", function (w,lx,ly,button)
	if button == 4 then awful.spawn("pamixer -i 5") 
		else if button == 5 then awful.spawn("pamixer -d 5")
			else if button == 3 then awful.spawn("pamixer -t") end
		end
	end
	update_widget()
end)
--}}}

--initial update
update_widget()

return {
	widget	= audiobox,
	update	= update_widget
}
