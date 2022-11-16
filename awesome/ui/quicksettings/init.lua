local wibox = require "wibox"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi

local notifwidget = require "ui.quicksettings.widgets.notifcenter"
local pctlwidget = require "ui.quicksettings.widgets.playerctl"

local function init(s)
    local cent_width = dpi(450) --math.ceil(s.geometry.width/4.5)
    --[[local layout = wibox.widget {
        layout = wibox.layout.grid,
        spacing = dpi(5)
    }

    layout:add_widget_at(calendar, 1, 1, 1, 1)
    layout:add_widget_at(notifwidget, 2, 1, 4, 1)
    ]]
    s.notifcenter = wibox {
        screen = s,
        x = s.geometry.x + s.geometry.width - cent_width - 2*beautiful.useless_gap,-- - beautiful.border_width,
        y = s.geometry.y + beautiful.wibar_height + 2*beautiful.useless_gap,
        width = cent_width,
        height = s.geometry.height - beautiful.wibar_height - 4*beautiful.useless_gap,-- - 2*beautiful.border_width - 6*beautiful.useless_gap, --bottom gap
        ontop = true,
        visible = false,
        --shape = beautiful.theme_shape,
        widget = wibox.widget {
            widget = wibox.container.margin,
            margins = dpi(5),
			{
				layout = wibox.layout.fixed.vertical,
				spacing = dpi(5),
				pctlwidget,
				notifwidget
			}
        }
    }
    function s.notifcenter:show()
        self.visible = true
    end
    function s.notifcenter:hide()
        self.visible = false
    end
end

local function show(s)
    s.notifcenter:show()
end

local function hide(s)
    s.notifcenter:hide()
end

return {
    init = init,
    show = show,
    hide = hide
}
