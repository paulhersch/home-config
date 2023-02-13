local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local wibox = require("wibox")

local function setup_titlebars(c)
    local top = awful.titlebar(c, {
        bg_normal = beautiful.bg_focus_dark,
        bg_focus = beautiful.bg_focus,
        bg_urgent = beautiful.border_color_urgent,
        fg_normal = beautiful.fg_normal,
        fg_focus = beautiful.fg_focus,
        fg_urgent = beautiful.white
    })
    top:setup {
        buttons = {
            awful.button({ }, 1, function()
                c:activate { context = "titlebar", action = "mouse_move"  }
            end),
            awful.button({ }, 3, function()
                c:activate { context = "titlebar", action = "mouse_resize"}
            end),
        },
        layout = wibox.layout.fixed.horizontal,
        {
            widget = wibox.container.margin,
            margins = dpi(5),
            awful.titlebar.widget.titlewidget(c)
        }
    }
end

local function toggle_by_floating(c)
    if not c.floating then
        awful.titlebar.hide(c, "top")
    else
        awful.titlebar.show(c, "top")
    end
end

client.connect_signal("request::titlebars", function (c, _, _)
    setup_titlebars(c)
    toggle_by_floating(c)

    c:connect_signal("property::floating", function ()
        toggle_by_floating(c)
    end)
end)
