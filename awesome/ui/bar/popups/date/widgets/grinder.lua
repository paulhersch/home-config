local wibox = require "wibox"
local beautiful = require "beautiful"
local gears = require "gears"
local dpi = beautiful.xresources.apply_dpi
local awful = require "awful"

local helpers = require "helpers"

local P = {}

P.time = 0
P.start_btn = helpers.pointer_on_focus(wibox.widget {
    id = 'button_bg',
    widget = wibox.container.background,
    bg = beautiful.bg_1,
    shape = beautiful.theme_shape,
    buttons = awful.button {
        modifiers = {},
        button = 1,
        on_press = function ()
            if P.updater.started then
                P.updater:stop()
                P.start_btn:get_children_by_id('text')[1].text = 'Start'
            else
                P.updater:start()
                P.start_btn:get_children_by_id('text')[1].text = 'Stop'
            end
        end
    },
    {
        widget = wibox.container.margin,
        margins = dpi(5),
        {
            id = 'text',
            widget = wibox.widget.textbox,
            font = beautiful.font .. " 10",
            text = 'Start',
        }
    }
})

P.start_btn:connect_signal("mouse::enter",function ()
    P.start_btn.bg = beautiful.bg_2
end)
P.start_btn:connect_signal("mouse::leave",function ()
    P.start_btn.bg = beautiful.bg_1
end)

P.widget = wibox.widget {
    widget = wibox.container.background,
    bg = beautiful.bg_1,
    shape = beautiful.theme_shape,
    {
        widget = wibox.container.margin,
        margins = dpi(5),
        {
            layout = wibox.layout.align.vertical,
            {
                widget = wibox.container.margin,
                margins = {
                    bottom = dpi(5)
                },
                {
                    widget = wibox.container.place,
                    halign = 'center',
                    valign = 'center',
                    P.start_btn
                }
            },
            {
                id = 'second',
                widget = wibox.container.arcchart,
                paddings = dpi(3),
                colors = { beautiful.fg_normal },
                max_value = 60,
                thickness = dpi(4),
                forced_height = dpi(70),
                {
                    id = 'minute',
                    widget = wibox.container.arcchart,
                    paddings = dpi(3),
                    colors = { beautiful.grey },
                    max_value = 60,
                    thickness = dpi(4),
                    {
                        id = 'hour',
                        widget = wibox.container.arcchart,
                        paddings = dpi(5),
                        colors = { beautiful.bg_2 },
                        max_value = 24,
                        thickness = dpi(4),
                        wibox.widget.base.make_widget()
                    }
                }
            },
            {
                widget = wibox.container.margin,
                margins = {
                    top = dpi(5)
                },
                {
                    widget = wibox.container.place,
                    halign = 'center',
                    {
                        id = 'time',
                        widget = wibox.widget.textbox,
                        font = beautiful.font .. " 10",
                        text = ""
                    }
                }
            }
        }
    }
}

P.update = function()
    local h,m,s = math.floor(P.time/3600), math.floor(P.time/60) % 60, P.time % 60
    P.widget:get_children_by_id('hour')[1].values = { h }
    P.widget:get_children_by_id('minute')[1].values = { m }
    P.widget:get_children_by_id('second')[1].values = { s }
    P.widget:get_children_by_id('time')[1].text = (h ~= 0 and h .. "h " or "") .. m .. "m " .. s .. "s"
end

P.updater = gears.timer {
    timeout = 1,
    callback = function ()
        P.time = P.time + 1
        P.update()
    end
}

return P.widget
