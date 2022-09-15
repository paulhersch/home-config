local wibox = require "wibox"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi

local widget = require "ui.notifcenter.widget"

local function init(s)
    local cent_width = dpi(400)
    s.notifcenter = wibox {
        screen = s,
        x = s.geometry.x + s.geometry.width - cent_width - 2*beautiful.useless_gap,-- - beautiful.border_width,
        y = s.geometry.y + beautiful.wibar_height + 2*beautiful.useless_gap,
        width = cent_width,
        height = s.geometry.height - beautiful.wibar_height - 4*beautiful.useless_gap,-- - 2*beautiful.border_width - 6*beautiful.useless_gap, --bottom gap
        ontop = true,
        visible = false,
--        border_width = beautiful.border_width,
--        border_color = beautiful.bg_focus,
        shape = beautiful.theme_shape,
        widget = wibox.widget {
            widget = wibox.container.margin,
            margins = dpi(5),
            widget
        }
    }
    --[[s.notifcenter.slide = rubato.timed {
        rate = 60,
        duration = 0.3,
        intro = 0.1,
        outro = 0.1,
        pos = 1,
        easing = rubato.easing.linear,
        subscribed = function (pos)
            s.notifcenter.visible = pos < 1
            --s.notifcenter.height = 5 + pos * (s.geometry.height - beautiful.wibar_height - 4*beautiful.useless_gap - 5)
            s.notifcenter.x = s.geometry.x + s.geometry.width - s.notifcenter.width - 2*beautiful.useless_gap + pos * cent_width
        end
    }]]
    function s.notifcenter:show()
        self.visible = true
        --self.slide.target = 0
    end
    function s.notifcenter:hide()
        self.visible = false
        --self.slide.target = 1
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
