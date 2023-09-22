local wibox = require "wibox"
local dpi = require "beautiful.xresources".apply_dpi
local beautiful = require "beautiful"
local PopupBase = require("ui.bar.popups.base").new
local Description = require("ui.components.container").description

local calendar = Description {
    description = "Calendar",
    widget = require "ui.bar.popups.date.widgets.calendar"
}

local layouts = Description {
    description = "Layoutswitcher",
    widget = require "ui.bar.popups.date.widgets.layout"
}

local grindtimer = Description {
    description = "Timer",
    widget = require "ui.bar.popups.date.widgets.grinder"
}

local m = {}
local p = {}

p.layout = wibox.widget {
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

p.layout:add_widget_at(calendar, 1, 3, 3, 3)
p.layout:add_widget_at(layouts, 1, 1, 1, 2)
p.layout:add_widget_at(grindtimer,2,1,2,2)

p.widget = wibox.widget {
    widget = wibox.container.margin,
    margins = dpi(5),
    p.layout
}

---@param bar any The bar this widget connects to
---@return PopupWidget
m.init = function (bar)
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
        widget = p.widget,
        anchor = "right"
    }
    ret:register_bar(bar)
    ret:show_trigger()

    return ret
end

return setmetatable(m, {__call = m.init})
