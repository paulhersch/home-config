local wibox = require "wibox"
local awful = require "awful"
local naughty = require "naughty"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local gears = require "gears"
local helpers = require "helpers"

local iconsdir = gears.filesystem.get_configuration_dir() .. "assets/titlebarbuttons/"
local mat_icons = gears.filesystem.get_configuration_dir() .. "assets/materialicons/"

local recycler = require "plugins.awesome-widgets.recycler"
local rubato = require "plugins.rubato"

local notifications
local function cross_enter (self, _)
    self:get_children_by_id('remove')[1]:set_image(gears.color.recolor_image(iconsdir .. "close.svg", beautiful.red))
end
local function cross_leave (self, _)
    self:get_children_by_id('remove')[1]:set_image(gears.color.recolor_image(iconsdir .. "close.svg", beautiful.fg_normal))
end

notifications = recycler(
    function()
        local w = wibox.widget {
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
                                id = 'title',
                                widget = wibox.widget.textbox,
                                font = beautiful.font_bold .. " 12",
                                --text = n.title
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
                                    --buttons =
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
                        {
                            widget = wibox.container.margin,
                            margins = dpi(5),
                            {
                                id = 'icon',
                                widget = wibox.widget.imagebox,
--                                image = n.icon,
                                resize = true,
                                forced_width = 0,
                                forced_height = 0,
                                clip_shape = beautiful.theme_shape
                            }
                        },
                        {
                            id = 'text',
                            widget = wibox.widget.textbox,
                            font = beautiful.font_thin .. " 10",
--                            text = n.message
                        }
                    }
                }
            }
        }
        function w:populate(n)
            self:get_children_by_id('remove')[1]:connect_signal("mouse::enter", function() cross_enter(w) end)
            self:get_children_by_id('remove')[1]:connect_signal("mouse::leave", function() cross_leave(w) end)
            self:get_children_by_id('title')[1].text = n.title
            self:get_children_by_id('text')[1].text = n.message
            self:get_children_by_id('icon')[1]:set_image(n.icon)
            self:get_children_by_id('icon')[1].forced_height = dpi(40)
            self:get_children_by_id('icon')[1].forced_width = dpi(40)
            self:get_children_by_id('remove')[1]:add_button(
                awful.button {
                    modifiers = {},
                        button = 1,
                        on_press = function ()
                            self:get_children_by_id('remove')[1]:disconnect_signal("mouse::enter", cross_enter)
                            self:get_children_by_id('remove')[1]:disconnect_signal("mouse::leave", cross_leave)
                            notifications:remove(self)
                            collectgarbage("collect")
                            end
                }
            )
        end
        return w
    end,
    {
        padx = 0,
        pady = 0,
        spacing = dpi(5),
        rubato_lib = rubato,
        pos_const = function ()
            return rubato.timed { duration = 0.1, intro = 0.05, prop_intro = true, rate = 60 }
        end
    }
)


--notifications = wibox.widget {
--    layout = wibox.layout.fixed.vertical,
--    spacing = dpi(5)
--}

local notifbox = wibox.widget { --empty because it will be filled with the update function
    layout = wibox.layout.fixed.vertical,
    spacing = dpi(5),
    {
        widget = wibox.container.background,
        bg = beautiful.bg_focus_dark,
        shape = beautiful.theme_shape,
        {
            widget = wibox.container.margin,
            margins = dpi(5),
            {
                layout = wibox.layout.fixed.horizontal,
                {
                    widget = wibox.widget.textbox,
                    text = "clear all",
                    font = beautiful.font .. " 13"
                },
                {
                    id = 'clear_button',
                    widget = wibox.container.place,
                    valign = 'center',
                    halign = 'right',
                    fill_horizontal = true,
                    {
                        widget = wibox.widget.imagebox,
                        image = gears.color.recolor_image(mat_icons .. "clear_all.svg", beautiful.fg_focus),
                        resize = true,
                        forced_height = beautiful.get_font_height(beautiful.font .. " 13"),
                        forced_width = beautiful.get_font_height(beautiful.font .. " 13")
                    },
                    buttons = awful.button {
                        modifiers = {},
                        button = 1,
                        on_press = function ()
                            --notifications:reset()
                            notifications:set_children() --clears
                        end
                    }
                }
            }
        }
    },
    notifications
}
helpers.pointer_on_focus(notifbox:get_children_by_id('clear_button')[1])

local function add_notif (n)
    if n.app_name ~= 'Spotify' then --ignore spotify notifications
        notifications:add_at(1,n)
        --[[local w
        local function cross_enter ()
            w:get_children_by_id('remove')[1]:set_image(gears.color.recolor_image(iconsdir .. "close.svg", beautiful.red))
        end
        local function cross_leave ()
            w:get_children_by_id('remove')[1]:set_image(gears.color.recolor_image(iconsdir .. "close.svg", beautiful.fg_normal))
        end
        w = wibox.widget {
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
                                            w:get_children_by_id('remove')[1]:disconnect_signal("mouse::enter", cross_enter)
                                            w:get_children_by_id('remove')[1]:disconnect_signal("mouse::leave", cross_leave)
                                            notifications:remove_widgets(w)
                                            w = nil
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
        w:get_children_by_id('remove')[1]:connect_signal("mouse::enter", cross_enter)
        w:get_children_by_id('remove')[1]:connect_signal("mouse::leave", cross_leave)

        --always insert at the top of the widget
        notifications:insert(1,w)]]
    end
end

naughty.connect_signal("request::display", function(n)
    add_notif(n)
end)

return notifbox
