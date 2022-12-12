local wibox = require "wibox"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi

local notifwidget = require "ui.quicksettings.widgets.notifcenter"
local pctlwidget = require "ui.quicksettings.widgets.playerctl"
local volumewidget = require "ui.quicksettings.widgets.volume"

local function init(s)
    local cent_width = dpi(450)
	local height = s.geometry.height*(2/5)
    s.quicksettings = wibox {
        screen = s,
        x = s.geometry.x + s.geometry.width - cent_width - 2*beautiful.useless_gap,
        y = s.geometry.y + s.geometry.height - (2*beautiful.useless_gap + beautiful.wibar_height + height),
        width = cent_width,
        height = height,
        ontop = true,
        visible = false,
        widget = wibox.widget {
            widget = wibox.container.margin,
            margins = dpi(5),
			{
				layout = wibox.layout.fixed.vertical,
				spacing = dpi(5),
				volumewidget,
				pctlwidget,
				notifwidget
			}
        }
    }
    function s.quicksettings:show()
        self.visible = true
    end
    function s.quicksettings:hide()
        self.visible = false
    end
end

local function show(s)
    s.quicksettings.visible = true
end

local function hide(s)
    s.quicksettings.visible = false
end

return {
    init = init,
    show = show,
    hide = hide
}
