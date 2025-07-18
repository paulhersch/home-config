local awful = require "awful"
local beautiful = require "beautiful"
local fs = require "gears.filesystem"
local awesome = awesome

local icons = fs.get_configuration_dir() .. "/assets/materialicons/"

local menu_items = {
	{
		"Awesome",
        {
            {
                "restart",
                function ()
                    awesome.restart()
                end
            },
            {
                "logout",
                function ()
                    awful.spawn.spawn("pkill awesome")
                end
            }
        },
		beautiful.awesome_icon
	},
	{
		"Display",
		function ()
		    awful.spawn.spawn("lxrandr")
		end,
        icons .. "display_settings.svg"
	}
}

local menu = awful.menu {
	items = menu_items,
    auto_expand = true
}

-- mousebindings
awful.mouse.append_global_mousebindings {
	awful.button {
		modifiers = {},
		button = 3,
		on_press = function ()
			menu:toggle()
		end
	}
}

awful.mouse.append_global_mousebindings {
	awful.button {
		modifiers = {},
		button = 1,
		on_press = function ()
			menu:hide()
		end
	}
}
