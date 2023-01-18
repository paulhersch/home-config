local awful = require "awful"
local beautiful = require "beautiful"
local naughty = require "naughty"
local wibox = require "wibox"
local dpi = beautiful.xresources.apply_dpi

local menu_items = {
	{
		"A",
		function ()
			naughty.notification { message = "AAAA" }
		end,
		beautiful.awesome_icon
	},
	{
		"B",
		{
			{ "C", function ()
			end },
			{ "D", function ()
			end }
		}
	}
}

--random attempt of awful.menu rewrite
--[[
local function _generate_widget(item)
	local item_widget = wibox.widget {
		widget = wibox.container.margin,
		margins = dpi(5),
		{
			widget = wibox.container.background,
			id = "hl_bg",
			bg = beautiful.menu_bg_normal,
			fg = beautiful.menu_fg_normal,
			{
				widget = wibox.container.margin,
				margins = dpi(5),
				{
					layout = wibox.layout.align.horizontal,
					expand = 'inside',
					forced_height = beautiful.get_font_height(beautiful.menu_font),
					{
						widget = wibox.widget.imagebox,
						image = item[3] and item[3] or nil
					},
					{
						widget = wibox.widget.textbox,
						text = item[1]
					},
					{
						widget = wibox.widget.imagebox,
						image = type(item[2]) == "table" and beautiful.menu_submenu_icon or nil
					}
				}
			}
		}
	}
	--attach submenu if found
	item_widget:add_button( awful.button {
		modifiers = {},
		button = 1,
		on_press = item[2]
	})
	item_widget:connect_signal("mouse::enter", function ()
		item_widget:get_children_by_id("hl_bg")[1].bg = beautiful.menu_bg_focus
		item_widget:get_children_by_id("hl_bg")[1].fg = beautiful.menu_fg_focus
	end)
	item_widget:connect_signal("mouse::leave", function ()
		item_widget:get_children_by_id("hl_bg")[1].bg = beautiful.menu_bg_normal
		item_widget:get_children_by_id("hl_bg")[1].fg = beautiful.menu_fg_normal
	end)

	return item_widget
end

local function _popup_from_list(layout_widget)
	return awful.popup {
		widget = layout_widget,
		border_width = beautiful.menu_border_width,
		border_color = beautiful.menu_border_color,
		ontop = true,
		visible = false,
		placement = function (d, args)
				--here: d == self
				if args.parent then
					d:move_next_to(args.parent)
				else
					awful.placement.next_to_mouse(d, args)
				end
		end
	}
end

local function _create_menu_widget(items)
	for _, item in ipairs(items) do
		local w
		if type(item[2]) == "table" then
			local submenu = _create_menu_widget(item[2])
			w = _generate_widget(item)
		end
	end
end]]

local menu = awful.menu {
	items = menu_items
}

return menu
