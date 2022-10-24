local client = client
local awful = require "awful"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local wibox = require "wibox"
local gears = require "gears"

local icondir = gears.filesystem.get_configuration_dir() .. "assets/titlebarbuttons/"
local iconsize = beautiful.titlebar_height/2

local function create_bar_button(icon, button_callback, hover_color)
    local widget = wibox.widget {
        widget = wibox.container.place,
        halign = 'center',
        buttons = {
            awful.button {
                modkey = {},
                key = "LEFT",
                on_release = button_callback
            }
        },
        {
            widget = wibox.container.background,
            forced_width = iconsize,
            forced_height = iconsize,
            {
                id = 'img',
                widget = wibox.widget.imagebox,
                resize = true,
                image = gears.color.recolor_image(icon, beautiful.fg_normal)
            }
        }
    }
    widget:connect_signal("mouse::enter", function()
        widget:get_children_by_id('img')[1].image = gears.color.recolor_image(icon, hover_color)
    end)
    widget:connect_signal("mouse::leave", function()
        widget:get_children_by_id('img')[1].image = gears.color.recolor_image(icon, beautiful.fg_normal)
    end)
    return widget
end

client.connect_signal("request::titlebars", function (c)
    awful.titlebar (c,{
        size = beautiful.titlebar_height,
        position = "left",
        bg_normal = beautiful.bg_normal,
        bg_focus = beautiful.bg_normal,
        bg_urgent = beautiful.bg_normal,
        fg_normal = beautiful.fg_normal,
        fg_focus = beautiful.blue,
        fg_urgent = beautiful.red,
        font = beautiful.font
    }):setup {
        layout = wibox.layout.align.vertical,
        {
            widget = wibox.container.margin,
            margins = { top = beautiful.titlebar_height/3 },
            {
                layout = wibox.layout.fixed.vertical,
                spacing = beautiful.titlebar_height/3,
                create_bar_button(icondir .. "close.svg", function ()
                    c:kill()
                end, beautiful.red),
                create_bar_button(icondir .. "minimize.svg", function ()
                    c.minimized = not c.minimized
                end, beautiful.blue),
            }
        }
    }
end)
