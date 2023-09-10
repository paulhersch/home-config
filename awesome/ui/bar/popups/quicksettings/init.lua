local wibox = require "wibox"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local PopupBase = require("ui.bar.popups.base").new
local gfs = require("gears.filesystem")

local materialicons = gfs.get_configuration_dir() .. "assets/materialicons/"

local battery = require("ui.bar.popups.quicksettings.widgets.battery").widget

-- display stuff interactively, statekeeping
local p = {
    trigger = wibox.widget {
        widget = wibox.layout.fixed.horizontal,
        spacing = dpi(5),
        battery
    },
    pctl_symbol = wibox.widget.imagebox(materialicons .. "music_note.svg"),
    notif_symbol = wibox.widget.imagebox(materialicons .. "forum.svg"),
    notifwidget = nil,
    pctlwidget = nil,
}

local function abstract_show(name)
    if p[name .. "_shown"] then
        return
    end
    p.trigger:add(p[name .. "_symbol"])
    p[name .. "_shown"] = true
end

local function abstract_hide(name)
    if not p[name .. "_shown"] then
        return
    end
    p.trigger:remove_widgets(p[name .. "_symbol"])
    p[name .. "_shown"] = false
end

local m = {
    show_note = function ()
        abstract_show("pctl")
    end,
    hide_note = function ()
        abstract_hide("pctl")
    end,
    show_notif = function ()
        abstract_show("notif")
    end,
    hide_notif = function ()
        abstract_hide("notif")
    end,
    init = function (bar)
        -- cant require because loop -> set at init
        p.notifwidget = require "ui.bar.popups.quicksettings.widgets.notifcenter"
        p.pctlwidget = require "ui.bar.popups.quicksettings.widgets.playerctl"

        ---@class QuicksettingsPopup : PopupWidget
        local QuicksettingsPopup = PopupBase {
            anchor = "right",
            widget = wibox.widget {
                widget = wibox.container.margin,
                margins = dpi(10),
                forced_width = dpi(450),
                forced_height = dpi(800),
                {
                    layout = wibox.layout.fixed.vertical,
                    spacing = dpi(10),
                    -- volumewidget,
                    setmetatable({}, {__index = p.pctlwidget}),
                    setmetatable({}, {__index = p.notifwidget}),
                }
            },
            trigger = p.trigger
        }

        QuicksettingsPopup:register_bar(bar)
        QuicksettingsPopup:show_trigger()

        return QuicksettingsPopup
    end
}

return setmetatable(m, {__call = m.init})
