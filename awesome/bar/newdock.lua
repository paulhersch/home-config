local wibox = require "wibox"
local awful = require "awful"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local gears = require "gears"

local function init(s)

	local tasklist = awful.widget.tasklist {
		screen	= s,
		source	= function()
			local ret = {}
			for _,t in ipairs(s.tags) do
				gears.table.merge(ret, t:clients())
			end
			return ret
		end, --sorts clients in order of their tags
		filter = awful.widget.tasklist.filter.alltags,
		layout	= wibox.widget {
			layout = wibox.layout.fixed.horizontal
		},
--[[		widget_template =
		{
			{
				{
					widget	= awful.widget.clienticon
				},
				widget	= wibox.container.place,
				forced_height = dpi(30),
				halign	= 'center',
				valign	= 'center',
			},
			widget = wibox.container.margin,
			margins = dpi(5),
			create_callback = function (self, c, _, _)
				self:connect_signal("button::press", function (_, _, _, b)
					if b == 1 then
						c.first_tag:view_only()
						c:activate {
							raise = true,
							context = "dock"
						}
					end
				end)
			end
		}]]
	}

	s.dock = awful.popup {
		x = s.geometry.x +5 ,
		y = s.geometry.y + s.geometry.height - dpi(40),
		ontop = true,
		visible = true,
	--	screen = s,
		forced_height = dpi(40),
		forced_width = dpi(130),
		shape = beautiful.theme_shape,
		widget = wibox.widget {
			tasklist
		}
	}
--[[	s.dock:connect_signal("property::width", function() --for centered placement, wanted to keep the offset
		s.dock.x = s.geometry.x + s.geometry.width/2 - s.dock.width/2
	end)]]
end

return {
	init = init
}
