-- awesome_mode: api-level=5:screen=on

local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local ruled = require("ruled")
require("awful.autofocus")

local dpi	= beautiful.xresources.apply_dpi

require ("keybinds")

naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
        message = message
    }
end)

beautiful.init( gears.filesystem.get_configuration_dir() .. "theme.lua")
require ("bar")
--require ("titlebar")
--local nice = require ("nice")
--nice()

tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.tile,
        awful.layout.suit.floating,
        awful.layout.suit.tile.top,
        awful.layout.suit.fair.horizontal,
        awful.layout.suit.spiral,
        awful.layout.suit.corner.nw,
    })
end)

-- {{{ Wallpaper
screen.connect_signal("request::wallpaper", function(s)
--[[	awful.wallpaper {
		screen = s,
		widget = {
			image		= beautiful.wallpaper,
			widget		= wibox.widget.imagebox,
			resize		= true,
			scaling_quality	= 'best',
			horizontal_fit_policy='fit'
		}
	}]]
	gears.wallpaper.maximized(beautiful.wallpaper, s)
end)
--this is just for shits and giggles
--[[awful.popup {
    widget = {
        {
            {
                text = "Activate Linux",
                font = beautiful.font .. " 20",
                widget = wibox.widget.textbox
            },
            {
                text = "Go to Settings to activate Linux.",
                font = beautiful.font .. " 15",
                widget = wibox.widget.textbox
            },
            layout = wibox.layout.fixed.vertical
        },
        margins = 30,
        widget = wibox.container.margin
    },
    opacity = 0.5,
    bg = "#00000000",
    type = "desktop",
    visible = true,
    ontop = true,
    input_passthrough = true,
    placement = awful.placement.bottom_right
}]]
-- }}}

screen.connect_signal("request::desktop_decoration", function(s)
	awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
end)

-- client management {{{
client.connect_signal("mouse::enter", function(c)
	c:activate { context = "mouse_enter", raise = false }
end)

client.connect_signal("request::manage", function(c)
	if c.floating then
		awful.placement.centered(c)
		c:raise()
	else c:to_secondary_section() end
	c.shape = c.fullscreen and gears.shape.rectangle or beautiful.theme_shape
end)

client.connect_signal("property::fullscreen", function(c)
	c.shape = c.fullscreen and gears.shape.rectangle or beautiful.theme_shape
end)
--}}}

-- rules {{{
ruled.client.connect_signal("request::rules", function()
	ruled.client.append_rule {
		id         = "titlebars",
		rule_any   = { type = { "normal", "dialog" } },
		properties = { titlebars_enabled = true },
	}
	ruled.client.append_rule {
		id = "floating_startup",
		rule = {},
		except_any = { type = { "normal", "dialog" } },
		properties = { floating = true, placement = awful.placement.centered }
	}
	ruled.client.append_rule {
		rule_any = {
			class = { "Thunar", "Pcmanfm", "Galculator" }
		},
		properties = {
			floating= true,
			width	= 650,
			height	= 480
		},
	}
end)
--}}}

-- {{{ Notifications

ruled.notification.connect_signal('request::rules', function()
    -- All notifications will match this rule.
    ruled.notification.append_rule {
        rule       = { },
        properties = {
            screen           = awful.screen.preferred,
            implicit_timeout = 5,
        }
    }
end)

naughty.connect_signal("request::display", function(n)
    naughty.layout.box { notification = n }
end)

-- }}}

-- Autostart {{{
awful.spawn("nm-applet")
awful.spawn("blueman-applet")
awful.spawn("xfce4-clipman")
awful.spawn("redshift -O 4600K -P")
awful.spawn("picom --config " .. os.getenv("HOME") .. "/.config/awesome/configs/picom.conf")
-- }}}
