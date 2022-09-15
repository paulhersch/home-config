local wibox	= require "wibox"
local beautiful	= require "beautiful"
local gears	= require "gears"
local awful	= require "awful"
local naughty	= require "naughty"

local dpi = beautiful.xresources.apply_dpi

local uPower	= require "plugins.uPower"

--here I am using the awesome-battery_widget from AireOne, slightly renamed for simplicity
local iconsdir	= gears.filesystem.get_configuration_dir() .. "assets/materialicons/"
local batshape = function(cr,w,h) return gears.shape.rounded_rect(cr,w,h,2) end
local chel = require "helpers".color
--[[local symbol = wibox.widget {
	id	= 'symbol',
	widget	= wibox.widget.imagebox,
	resize	= true,
}]]
local symbol = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    {
        widget = wibox.container.place,
        valign ='center',
        {
            id = 'end',
            widget = wibox.container.background,
            bg = beautiful.fg_normal,
            forced_width = dpi(0),
            forced_height = dpi(0),
            shape = function (cr,w,h)
                return gears.shape.partially_rounded_rect(cr,w,h,true,false,false,true,dpi(2))
            end,
            wibox.widget.base.make_widget()
        }
    },
    {
        widget = wibox.container.rotate,
        direction = 'south',
        {
            id = 'val',
            widget = wibox.widget.progressbar,
            border_width = dpi(2),
            paddings = dpi(2),
            border_color = beautiful.fg_normal,
            color = beautiful.green,
            background_color = beautiful.bg_normal,
            shape = batshape,
            --bar_shape = batshape,
            max_value = 100,
            value = 50,
            forced_height = dpi(0),
            forced_width = dpi(0),
        }
    }
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

local r_d, g_d, b_d = chel.col_diff(beautiful.green, beautiful.red)

batterywidget:connect_signal("upower::update", function (_, device)
	if device.kind == 2 then --checks if device is a battery
		tooltip.text = device.state == 2
			and device.percentage .. "%, noch " .. uPower.to_clock(device.time_to_empty)
			or  device.percentage .. "%, noch " .. uPower.to_clock(device.time_to_full)
        --this creates some colors in between green and red with some offsets
        local perc_float = device.percentage > 80 and 0 or (device.percentage > 20 and 1 - (device.percentage - 20)/60 or 1)
		symbol:get_children_by_id('val')[1].value = device.percentage
		symbol:get_children_by_id('val')[1].forced_height = dpi(14)
        symbol:get_children_by_id('val')[1].forced_width = dpi(27)
        symbol:get_children_by_id('val')[1].color = chel.col_shift(beautiful.green, r_d*perc_float*255, g_d*perc_float*255, b_d*perc_float*255)
        symbol:get_children_by_id('end')[1].forced_width = dpi(2)
        symbol:get_children_by_id('end')[1].forced_height = dpi(6)
        --display warning if battery is below 20%
        if device.state == 2 and device.percentage < 20 then
            naughty.notification{
                title = "battery low!",
                message = "battery at " .. device.percentage .. " percent, charge up!",
                icon = iconsdir .. "battery_alert.svg"
            }
        end
	end
end)

return {
	widget = batterywidget
}
