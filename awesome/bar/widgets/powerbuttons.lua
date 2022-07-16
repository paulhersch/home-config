local wibox = require "wibox"
local awful = require "awful"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi

local iconsdir = require("gears.filesystem").get_configuration_dir() .. "/assets/materialicons/"

local menu = awful.menu {
    items = { { "poweroff", "" } }
}

local poff = wibox.widget {
    widget = wibox.container.place,
    fill_horizontal = true,
    halign = 'center',
    {
        widget = wibox.container.background,
        shape = beautiful.theme_shape,
        bg = beautiful.red,
        {
            widget = wibox.container.margin,
            margins = dpi(5),
            {
                widget = wibox.widget.imagebox,
                image = iconsdir .. "poweroff.svg",
                resize = true,
            }
        },
        buttons = awful.button {
            modifiers = {},
            button = 1,
            on_press = function ()
                menu:show()
            end
        }
    }
}

local lock = wibox.widget {
    widget = wibox.container.place,
    fill_horizontal = true,
    halign = 'center',
    {
        widget = wibox.container.background,
        shape = beautiful.theme_shape,
        bg = beautiful.yellow,
        {
            widget = wibox.container.margin,
            margins = dpi(5),
            {
                widget = wibox.widget.imagebox,
                image = iconsdir .. "lock.svg",
                resize = true,
            }
        }
    }
}

require("helpers").pointer_on_focus(poff)
require("helpers").pointer_on_focus(lock)

local btns = wibox.widget {
    widget = wibox.container.background,
    bg = beautiful.bg_focus,
    shape = beautiful.theme_shape,
    {
        widget = wibox.container.place,
        valign = 'center',
        halign = 'center',
        {
            widget = wibox.container.margin,
            margins = dpi(5),
            {
                layout = wibox.layout.flex.horizontal,
                spacing = dpi(5),
                lock,
                poff
            }
        }
    }
}

return btns
