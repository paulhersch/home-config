local awful = require("awful")
local client = client
require("awful.autofocus")

client.connect_signal("mouse::enter", function(c)
	c:activate {
        context = "mouse_enter",
        raise = false
    }
end)

client.connect_signal("request::manage", function(c)
    c:move_to_screen(awful.screen.focused())
	if c.floating then
		awful.placement.centered(c)
		c:raise()
	else
        c:to_secondary_section()
    end
    c:activate {
        raise = true
    }
    if not c.requests_no_titlebar then
        c:emit_signal("request::titlebars", c)
    end
end)
