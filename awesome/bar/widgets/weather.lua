local awful	= require "awful"
local wibox = require "wibox"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local json = require "plugins.json.json"

local weather = wibox.widget {
	widget = wibox.container.margin,
	margins = dpi(10),
	{
		layout = wibox.layout.fixed.vertical,
		{
			id = 'icon',
			widget = wibox.widget.textbox,
			align = 'center',
			valign = 'center',
			font = beautiful.icon_font .. " 80",
			text = ""
		},
		{
			id = 'temp',
			widget = wibox.widget.textbox,
			font = beautiful.font .. " 12",
			text = "no °C",
			align = 'right'
		},
		{
			id = 'felt_temp',
			widget = wibox.widget.textbox,
			font = beautiful.font_thin .. " 10",
			text = "doesn't feel like anything",
			align = 'right'
		}
	}
}

local function updater (api_key)
	local call = "curl \"https://api.openweathermap.org/data/2.5/onecall?units=metric&lat=51.50&lon=12&exclude=minutely,hourly,daily&appid=" .. api_key .. "\""
	awful.spawn.easy_async_with_shell(call, function (out, _, _, code)
		print(call .. "     " .. out .. "     " .. code)
		print(code == 0 and "true" or "false")
		if code == 0 then
			print("after decode")
			local data = json.decode(out)
			print(data.current.temp)
			print(data.current.feels_like)
			weather:get_children_by_id('temp')[1].text = data.current.temp .. " °C"
			weather:get_children_by_id('felt_temp')[1].text = data.current.feels_like .. " °C"
		end
	end)
end

return {
	widget = weather,
	update = updater
}
