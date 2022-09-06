local naughty = require("naughty")
local beautiful = require("beautiful")
local wibox = require("wibox")
local awful = require("awful")
local dpi = beautiful.xresources.apply_dpi

local helpers = require "helpers"

local dnd = false

local n = {}
n.enable = function ()
    dnd = false
end

n.disable = function ()
    dnd = false
end

--[[n.actions_template = wibox.widget {
    widget = wibox.container.background,
    bg = beautiful.bg_focus,
    shape = beautiful.shape,
    {
        widget = wibox.container.margin,
        margins = dpi(5),
        {
            widget = wibox.widget.textbox,
            id = 'text_role',
            font = beautiful.font_thin .. " 10"
        }
    }
}

n.actions_template:connect_signal("mouse::enter",function ()
    n.actions_template.bg = beautiful.bg_focus_dark
end)
n.actions_template:connect_signal("mouse::leave",function ()
    n.actions_template.bg = beautiful.bg_focus
end)
helpers.pointer_on_focus(n.actions_template)
]]

local actionlist = require("naughty.list.actions")
local wicon      = require("naughty.widget.icon")
local wtitle     = require("naughty.widget.title")
local wmessage   = require("naughty.widget.message")

local template = {
    {
        {
            {
                widget = wibox.container.background,
--                bg = beautiful.bg_focus_dark,
                {
                    wtitle,
                    widget = wibox.container.margin,
                    margins = {
                        top = dpi(5),
                        left = dpi(5),
                        right = dpi(5)
                    }
                }
            },
            {
                {
                    {
                        {
                            {
                                {
                                    wicon,
                                    widget = wibox.container.background,
                                    shape = beautiful.theme_shape
                                },
                                widget = wibox.container.place,
                                valign = 'center'
                            },
                            wmessage,
                            spacing = dpi(5),
                            layout  = wibox.layout.fixed.horizontal,
                        },
                        widget = wibox.container.margin,
                        margins = dpi(5)
                    },
                    {
                        base_layout = {
                            layout = wibox.layout.flex.horizontal,
                            spacing = dpi(5)
                        },
                        --widget_template = {
                        --    
                        --},
                        widget = naughty.list.actions,
                    },
                    layout  = wibox.layout.fixed.vertical,
                },
                id     = "background_role",
                widget = wibox.container.background,
            },
            spacing = dpi(5),
            layout  = wibox.layout.fixed.vertical,
        },
        widget = wibox.container.background,
        shape = beautiful.theme_shape,
        bg = beautiful.bg_focus_dark
    },
    widget = wibox.container.constraint,
    strategy = 'max',
    width = dpi(500)
}

naughty.config.padding = 2*beautiful.useless_gap
naughty.config.spacing = 2*beautiful.useless_gap
naughty.config.defaults.position = "bottom_left"
naughty.config.defaults.border_width = 0


local function init ()
    naughty.connect_signal("request::display", function (notif)
        if not dnd then
            naughty.layout.box {
                notification = notif,
                --widget_template = template,
            }
        end
    end)
end

return {
    enable = n.enable,
    disable = n.disable,
    init = init
}
