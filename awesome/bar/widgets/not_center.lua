local wibox = require "wibox"
local awful = require "awful"
local naughty = require "naughty"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local gears = require "gears"

iconsdir = gears.filesystem.get_configuration_dir() .. "assets/titlebarbuttons/"

local notifbox = wibox.widget { --empty because it will be filled with the update function
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(5),
}

local function add_notif (n)
    local self
    local function cross_enter ()
        self:get_children_by_id('remove')[1]:set_image(gears.color.recolor_image(iconsdir .. "close.svg", beautiful.red))
    end
    local function cross_leave ()
        self:get_children_by_id('remove')[1]:set_image(gears.color.recolor_image(iconsdir .. "close.svg", beautiful.fg_normal))
    end
    self = wibox.widget {
        widget = wibox.container.background,
        bg = beautiful.bg_focus,
        shape = beautiful.theme_shape,
        {
            layout = wibox.layout.fixed.vertical,
            {
                widget = wibox.container.background,
                bg = beautiful.bg_focus_dark,
                {
                    widget = wibox.container.margin,
                    margins = dpi(5),
                    {
                        layout = wibox.layout.fixed.horizontal,
                        {
                            widget = wibox.widget.textbox,
                            font = beautiful.font_bold .. " 12",
                            text = n.title
                        },
                        {
                            widget = wibox.container.place,
                            fill_horizontal = true,
                            halign = 'right',
                            valign = 'center',
                            {
                                id = 'remove',
                                widget = wibox.widget.imagebox,
                                image = gears.color.recolor_image(iconsdir .. "close.svg", beautiful.fg_normal),
                                forced_height = beautiful.get_font_height(beautiful.font_bold .. " 12")*(2/3),
                                forced_width = beautiful.get_font_height(beautiful.font_bold .. " 12"),
                                buttons = awful.button {
                                    modifiers = {},
                                    button = 1,
                                    on_press = function ()
                                        self:get_children_by_id('remove')[1]:disconnect_signal("mouse::enter", cross_enter)
                                        self:get_children_by_id('remove')[1]:disconnect_signal("mouse::leave", cross_leave)
                                        notifbox:remove_widgets(self)
                                        self = nil
                                        collectgarbage("collect")
                                    end
                                }
                            }
                        }
                    }
                }
            },
            {
                widget = wibox.container.margin,
                margins = dpi(5),
                {
                    layout = wibox.layout.fixed.horizontal,
                    n.icon ~= nil and {
                        widget = wibox.container.margin,
                        margins = dpi(5),
                        {
                            id = 'icon',
                            widget = wibox.widget.imagebox,
                            image = n.icon,
                            resize = true,
                            forced_width = dpi(40),
                            forced_height = dpi(40),
                            clip_shape = beautiful.theme_shape
                        }
                    },
                    {
                        widget = wibox.widget.textbox,
                        font = beautiful.font_thin .. " 10",
                        text = n.message
                    }
                }
            }
        }
    }
    self:get_children_by_id('remove')[1]:connect_signal("mouse::enter", cross_enter)
    self:get_children_by_id('remove')[1]:connect_signal("mouse::leave", cross_leave)
    
    --always insert at the top of the widget
    notifbox:insert(1,self)
end

naughty.connect_signal("request::display", function(n)
    add_notif(n)
end)

return notifbox
