local awful = require("awful")

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
		})
	end)
end

return {
	init = init
}
