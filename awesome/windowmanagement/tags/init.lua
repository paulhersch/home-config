local awful = require("awful")

local tag = tag
local screen = screen

tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
		awful.layout.suit.corner.nw,
        awful.layout.suit.tile,
        awful.layout.suit.floating,
        awful.layout.suit.spiral,
    })
end)

screen.connect_signal("request::desktop_decoration", function(s)
	awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
end)
