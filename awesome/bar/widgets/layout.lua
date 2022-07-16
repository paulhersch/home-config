local awful = require "awful"
local wibox = require "wibox"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi

local widget = awful.widget.layoutlist {
    base_layout = wibox.widget {
        spacing         = dpi(5),
        forced_num_cols = dpi(3),
        layout          = wibox.layout.grid.vertical,
    },
    widget_template = {
        {
            {
                id            = 'icon_role',
                widget        = wibox.widget.imagebox,
            },
            margins = dpi(5),
            widget  = wibox.container.margin,
        },
        id              = 'background_role',
        forced_width    = dpi(58),
        forced_height   = dpi(58),
        shape           = beautiful.theme_shape,
        widget          = wibox.container.background,
        create_callback = function (self, _, _, _, _)
            require("helpers").pointer_on_focus(self)
        end
    }
}

return wibox.widget {
    widget = wibox.container.background,
    shape = beautiful.theme_shape,
    bg = beautiful.bg_focus,
    {
        widget = wibox.container.place,
        valign = 'center',
        halign = 'center',
        {
            widget = wibox.container.margin,
            margins = dpi(5),
            widget
        }
    }
}
