local awful = require("awful")
local rubato = require("plugins.rubato")
local dpi = require("beautiful").xresources.apply_dpi

--resize/move mode implementation + some keybinds
local in_resize_move = false
local remove_res_move_binds

local resize_move_step = dpi(40)
local resize_move_keys = {
    awful.key ({}, "w",
        function(c)
            c:geometry {
                x = c.x,
                y = c.y,
                width = c.width,
                height = c.height - resize_move_step
            }
        end
    ),
    awful.key ({}, "s",
        function(c)
            c:geometry {
                x = c.x,
                y = c.y,
                width = c.width,
                height = c.height + resize_move_step
            }
        end
    ),
    awful.key ({}, "a",
        function(c)
            c:geometry {
                x = c.x,
                y = c.y,
                width = c.width - resize_move_step,
                height = c.height
            }
        end
    ),
    awful.key ({}, "d",
        function(c)
            c:geometry {
                x = c.x,
                y = c.y,
                width = c.width + resize_move_step,
                height = c.height
            }
        end
    ),
    awful.key ({ "Shift" }, "a",
        function(c)
            c:geometry {
                x = c.x - resize_move_step,
                y = c.y,
                width = c.width,
                height = c.height
            }
        end
    ),
    awful.key ({ "Shift" }, "w",
        function(c)
            c:geometry {
                x = c.x,
                y = c.y - resize_move_step,
                width = c.width,
                height = c.height
            }
        end
    ),
    awful.key ({ "Shift" }, "s",
        function(c)
            c:geometry {
                x = c.x,
                y = c.y + resize_move_step,
                width = c.width,
                height = c.height
            }
        end
    ),
    awful.key ({ "Shift" }, "d",
        function(c)
            c:geometry {
                x = c.x + resize_move_step,
                y = c.y,
                width = c.width,
                height = c.height
            }
        end
    ),
    awful.key ({}, "Escape", function() remove_res_move_binds() in_resize_move = false end)
}

remove_res_move_binds = function()
    for _, k in ipairs(resize_move_keys) do
        awful.keyboard.remove_client_keybinding(k)
    end
end

local function init (modkey)
	client.connect_signal("request::default_mousebindings", function()
		awful.mouse.append_client_mousebindings({
			awful.button({ }, 1, function (c)
				c:activate { context = "mouse_click" }
			end),
			awful.button({ modkey }, 1, function (c)
				c:activate { context = "mouse_click", action = "mouse_move"  }
			end),
			awful.button({ modkey }, 3, function (c)
				c:activate { context = "mouse_click", action = "mouse_resize"}
			end),
		})
	end)
	client.connect_signal("request::default_keybindings", function()
		awful.keyboard.append_client_keybindings({
			awful.key({ modkey,           }, "f",
				function (c)
					c.fullscreen = not c.fullscreen
					c:raise()
				end,
				{description = "toggle fullscreen", group = "client"}),
			awful.key({ modkey }, "t",
				function(c)
					c.ontop = not c.ontop
				end),
			awful.key({ modkey }, "n",
				function(c)
						c.minimized = true
				end),
			awful.key({ modkey}, "m",
				function(c)
					c.maximized = not c.maximized
				end),
			awful.key({ modkey, "Shift"   }, "q",      function (c) c:kill() end,
				{description = "close", group = "client"}),
			awful.key({ modkey, "Shift" }, "space",  awful.client.floating.toggle,
				{description = "toggle floating", group = "client"}),
            awful.key({ modkey          }, "r", function ()
                in_resize_move = not in_resize_move
                if in_resize_move then
                    awful.keyboard.append_client_keybindings(resize_move_keys)
                else
                    remove_res_move_binds()
                end
            end,
                {description = "enter resize mode", group = "client"}),
		})
	end)
end

return {
	init = init
}
