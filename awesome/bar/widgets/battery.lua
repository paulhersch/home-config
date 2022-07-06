local wibox	= require "wibox"
local beautiful	= require "beautiful"
local gears	= require "gears"
local awful	= require "awful"
local naughty	= require "naughty"

local uPower	= require "plugins.uPower"

--here I am using the awesome-battery_widget from AireOne, slightly renamed for simplicity
local iconsdir	= gears.filesystem.get_configuration_dir() .. "assets/materialicons/"

local symbol = wibox.widget {
	id	= 'symbol',
	widget	= wibox.widget.imagebox,
	resize	= true,
}

local tooltip	= awful.tooltip {
	objects	= { symbol },
	bg	= beautiful.bg_normal,
	fg	= beautiful.fg_normal,
}

local batterywidget = uPower {
	instant_update		= true,
	device_path 		= '/org/freedesktop/UPower/devices/battery_BAT0',
	use_display_device  = true,
	widget_template		= symbol
}

batterywidget:connect_signal("upower::update", function (_, device)
	if device.kind == 2 then --checks if device is a battery
		tooltip.text = device.state == 2
			and device.percentage .. "%, noch " .. uPower.to_clock(device.time_to_empty)
			or  device.percentage .. "%, noch " .. uPower.to_clock(device.time_to_full)
		local icon = "battery_full.svg"
		if device.state == 2 then
			if	device.percentage >= 93
				then icon = "battery_full.svg"
			elseif	device.percentage < 93 and device.percentage >= 80
				then icon = "battery6.svg"
			elseif	device.percentage < 80 and device.percentage >= 68
				then icon = "battery5.svg"
			elseif	device.percentage < 68 and device.percentage >= 56
				then icon = "battery4.svg"
			elseif	device.percentage < 56 and device.percentage >= 43
				then icon = "battery3.svg"
			elseif	device.percentage < 43 and device.percentage >= 31
				then icon = "battery2.svg"
			elseif	device.percentage < 31 and device.percentage >= 18
				then icon = "battery1.svg"
			else	icon = "battery_alert.svg" end
		else
			icon = "bolt.svg"
		end
		if device.percentage <= 20 then
			naughty.notification({
				title	= "battery low",
				message	= "Your battery is at " .. device.percentage .. "%, you might want to grab a charger"
			})
		end
		symbol:get_children_by_id('symbol')[1].image = gears.color.recolor_image(iconsdir .. icon, beautiful.fg_focus)
	end
end)

return {
	widget = batterywidget
}
