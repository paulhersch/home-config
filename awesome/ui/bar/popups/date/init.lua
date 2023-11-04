local wibox = require "wibox"
local dpi = require "beautiful.xresources".apply_dpi
local beautiful = require "beautiful"
local PopupBase = require("ui.bar.popups.base").new
local Description = require("ui.components.container").description

local M = {}
local P = {}

P.calendar = Description {
    description = "Calendar",
    widget = require "ui.bar.popups.date.widgets.calendar"
}

P.layouts = Description {
    description = "Layoutswitcher",
    widget = require "ui.bar.popups.date.widgets.layout"
}

P.grindtimer = Description {
    description = "Timer",
    widget = require "ui.bar.popups.date.widgets.grinder"
}

P.layout = wibox.widget {
    layout        = wibox.layout.grid,
    homogeneous   = true,
    spacing = dpi(10),
	horizontal_expand = true,
	vertical_expand = true,
	forced_num_cols = 5,
    forced_num_rows = 3,
    forced_height = dpi(300),
    forced_width = dpi(500),
}

P.layout:add_widget_at(P.calendar, 1, 3, 3, 3)
P.layout:add_widget_at(P.layouts, 1, 1, 1, 2)
P.layout:add_widget_at(P.grindtimer,2,1,2,2)

P.widget = wibox.widget {
    widget = wibox.container.margin,
    margins = dpi(10),
    P.layout
}

---@param bar any The bar this widget connects to
---@return PopupWidget
M.init = function (bar)
    ---@class DatePopup : PopupWidget
    local ret = PopupBase {
        trigger = wibox.widget {
            layout = wibox.layout.fixed.horizontal,
            {
                widget = wibox.widget.textclock,
                format = "%H",
                font = beautiful.font_bold .. " 18"
            },
            {
                widget = wibox.container.background,
                fg = beautiful.gray,
                {
                    widget = wibox.widget.textclock,
                    format = "%M",
                    font = beautiful.font_bold .. " 18"
                }
            },
            {
                widget = wibox.container.margin,
                margins = dpi(5),
                wibox.widget.base.make_widget()
            },
            {
                widget = wibox.widget.textclock,
                font = beautiful.font .. " 11",
                format = "%A"
            }
        },
        widget = P.widget,
        anchor = "right"
    }
    ret:register_bar(bar)
    ret:show_trigger()

    return ret
end

return setmetatable(M, {__call = M.init})
