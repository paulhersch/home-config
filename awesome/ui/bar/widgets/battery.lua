local wibox	= require "wibox"
local beautiful	= require "beautiful"
local gears	= require "gears"
local awful	= require "awful"
local naughty	= require "naughty"

local dpi = beautiful.xresources.apply_dpi

--here I am using the awesome-battery_widget from AireOne, slightly renamed for simplicity
local uPower	= require "plugins.uPower"

local iconsdir	= gears.filesystem.get_configuration_dir() .. "assets/materialicons/"
local batshape = function(cr,w,h) return gears.shape.rounded_rect(cr,w,h,2) end
local chel = require "helpers".color
--[[local symbol = wibox.widget {
	id	= 'symbol',
	widget	= wibox.widget.imagebox,
	resize	= true,
}]]

local charge_indicator = wibox.widget {
    widget = wibox.container.rotate,
    direction = 'west',
    {
        widget = wibox.container.place,
        halign = 'center',
        {
            id = 'img',
            widget = wibox.widget.imagebox,
        }
    }
}
function charge_indicator:no_display()
    self:get_children_by_id('img')[1].image = nil
end

function charge_indicator:display()
    self:get_children_by_id('img')[1].image = gears.color.recolor_image(iconsdir .. "bolt.svg", beautiful.fg_normal)
end

local val = wibox.widget {
    widget = wibox.widget.progressbar,
    border_width = dpi(2),
    paddings = dpi(2),
    border_color = beautiful.fg_normal,
    color = beautiful.green,
    background_color = beautiful.bg_focus,
    shape = batshape,
    max_value = 100,
    value = 50,
}

local stack = wibox.widget {
    val,
    charge_indicator,
    layout = wibox.layout.stack,
    forced_width = 0
}

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
        stack
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
	widget_template		= {
        widget = wibox.container.margin,
        margins = { top = dpi(3), bottom = dpi(3) },
        symbol
    }
}

local r_d, g_d, b_d = chel.col_diff(beautiful.green, beautiful.red)

local lastpercnotif

batterywidget:connect_signal("upower::update", function (_, device)
	if device.kind == 2 then --checks if device is a battery
        local percentage = device.percentage
        --not really the correct way to determine the "discharging" state, but idc
        local discharging = device.state == 2 or device.state == 5 or device.state == 6
        if discharging then
            tooltip.text = percentage .. "%, noch " .. uPower.to_clock(device.time_to_empty)
            --display warning if battery is below 20% and we havent displayed a waring for that percentage already (upower sends 6 for some reason)
            if percentage < 20 and percentage ~= lastpercnotif then
                lastpercnotif = percentage
                naughty.notification{
                    title = "battery low!",
                    message = "battery at " .. percentage .. " percent, charge up!",
                    icon = gears.color.recolor_image(iconsdir .. "battery_alert.svg", beautiful.fg_normal)
                }
            end
            charge_indicator:no_display()
        elseif device.state == 1 then
            tooltip.text = percentage .. "%, noch " .. uPower.to_clock(device.time_to_full)
            lastpercnotif = -1
            charge_indicator:display()
            if percentage > 98 then
                naughty.notification {
                    title = "Baterry Full!",
                    message = "The battery is full, you can unplug now",
                    icon = gears.color.recolor_image(iconsdir .. "battery_full.svg", beautiful.fg_normal)
                }
            end
        end
        --this creates some colors in between green and red with some offsets
        local perc_float = percentage > 80 and 0 or (percentage > 10 and 1 - (percentage - 20)/70 or 1)
        val.value = percentage
        val.color = chel.col_shift(beautiful.green, r_d*perc_float*255, g_d*perc_float*255, b_d*perc_float*255)
        stack.forced_width = dpi(27)
        symbol:get_children_by_id('end')[1].forced_width = dpi(2)
        symbol:get_children_by_id('end')[1].forced_height = dpi(6)
	end
end)

return {
	widget = batterywidget
}
