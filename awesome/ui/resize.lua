local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local wibox = require("wibox")
local beautiful = require("beautiful")
local client = client
local settings = require("settings")
--resize/move mode implementation + some keybinds

local M = {}

M.resize_indicator = awful.popup {
    ontop = true,
    visible = false,
    widget = {
        widget = wibox.container.background,
        bg = beautiful.bg_1,
        {
            widget = wibox.container.margin,
            margins = dpi(10),
            {
                widget = wibox.widget.textbox,
                text = "resizing"
            }
        }
    }
}

M.update_popup_pos = function(c)
    awful.placement.centered(M.resize_indicator, {parent=c})
end

M.overlay_resize_indicator = function(c)
    M.resize_indicator.visible = true
    M.update_popup_pos(c)
    c:connect_signal("property::geometry", M.update_popup_pos)
end

M.remove_resize_indicator = function(c)
    M.resize_indicator.visible = false
    c:disconnect_signal("property::geometry", M.update_popup_pos)
end

M.stop_resize = function(c)
    M.remove_resize_indicator(c)
    for _, k in ipairs(M.resize_move_keys) do
        awful.keyboard.remove_client_keybinding(k)
    end
end

M.resize_move_step = dpi(40)

M.resize_move_keys = {
    awful.key ({}, "w",
        function(c)
            c:geometry {
                x = c.x,
                y = c.y,
                width = c.width,
                height = c.height - M.resize_move_step
            }
        end, {
            description = "decrease height",
            group = "client"
        }
    ),
    awful.key ({}, "s",
        function(c)
            c:geometry {
                x = c.x,
                y = c.y,
                width = c.width,
                height = c.height + M.resize_move_step
            }
        end, {
            description = "decrease height",
            group = "client"
        }
    ),
    awful.key ({}, "a",
        function(c)
            c:geometry {
                x = c.x,
                y = c.y,
                width = c.width - M.resize_move_step,
                height = c.height
            }
        end, {
            description = "decrease height",
            group = "client"
        }
    ),
    awful.key ({}, "d",
        function(c)
            c:geometry {
                x = c.x,
                y = c.y,
                width = c.width + M.resize_move_step,
                height = c.height
            }
        end, {
            description = "decrease height",
            group = "client"
        }
    ),
    awful.key ({ "Shift" }, "a",
        function(c)
            c:geometry {
                x = c.x - M.resize_move_step,
                y = c.y,
                width = c.width,
                height = c.height
            }
        end, {
            description = "decrease height",
            group = "client"
        }
    ),
    awful.key ({ "Shift" }, "w",
        function(c)
            c:geometry {
                x = c.x,
                y = c.y - M.resize_move_step,
                width = c.width,
                height = c.height
            }
        end, {
            description = "decrease height",
            group = "client"
        }
    ),
    awful.key ({ "Shift" }, "s",
        function(c)
            c:geometry {
                x = c.x,
                y = c.y + M.resize_move_step,
                width = c.width,
                height = c.height
            }
        end, {
            description = "decrease height",
            group = "client"
        }
    ),
    awful.key ({ "Shift" }, "d",
        function(c)
            c:geometry {
                x = c.x + M.resize_move_step,
                y = c.y,
                width = c.width,
                height = c.height
            }
        end, {
            description = "decrease height",
            group = "client"
        }
    ),
    awful.key ({}, "Escape", function(c) M.stop_resize(c) c.in_resize_move = false end)
}

client.connect_signal("request::default_keybindings", function ()
    awful.keyboard.append_client_keybindings({
        awful.key(
            {settings.get("modkey")},
            "r",
            function (c)
                if not(c.floating or (c:tags()[1].layout.name == "floating")) then
                    return
                end

                c.in_resize_move = not c.in_resize_move

                if c.in_resize_move then
                    awful.keyboard.append_client_keybindings(M.resize_move_keys)
                    M.overlay_resize_indicator(c)
                else
                    M.stop_resize(c)
                end
            end,
            {
                description = "enter resize mode",
                group = "client"
            }
        )
    })
end)
