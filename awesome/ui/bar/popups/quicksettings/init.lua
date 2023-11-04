local wibox = require "wibox"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local PopupBase = require("ui.bar.popups.base").new
local Details = require("ui.components.container").details
local gfs = require("gears.filesystem")

local materialicons = gfs.get_configuration_dir() .. "assets/materialicons/"

local battery = require("ui.bar.popups.quicksettings.widgets.battery").widget

-- display stuff interactively, statekeeping
local P = {
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

P.abstract_show = function(name)
    if P[name .. "_shown"] then
        return
    end
    P.trigger:insert(1, P[name .. "_symbol"])
    P[name .. "_shown"] = true
end

P.abstract_hide = function(name)
    if not P[name .. "_shown"] then
        return
    end
    P.trigger:remove_widgets(P[name .. "_symbol"])
    P[name .. "_shown"] = false
end

local M = {
    show_note = function ()
        P.abstract_show("pctl")
    end,
    hide_note = function ()
        P.abstract_hide("pctl")
    end,
    show_notif = function ()
        P.abstract_show("notif")
    end,
    hide_notif = function ()
        P.abstract_hide("notif")
    end,
    init = function (bar)
        -- cant require because loop -> set at init
        P.notifwidget = P.notifwidget or require "ui.bar.popups.quicksettings.widgets.notifcenter"
        P.pctlwidget = P.pctlwidget or require "ui.bar.popups.quicksettings.widgets.playerctl"

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
                    -- setmetatable({}, {__index = p.pctlwidget}),
                    -- setmetatable({}, {__index = p.notifwidget}),
                    P.pctlwidget,
                    P.notifwidget
                }
            },
            trigger = P.trigger
        }

        local old_show = QuicksettingsPopup.__show_popup
        function QuicksettingsPopup:__show_popup()
            P.pctlwidget:enable_updates()
            old_show(self)
        end
        local old_hide = QuicksettingsPopup.__hide_popup
        function QuicksettingsPopup:__hide_popup()
            old_hide(self)
            P.pctlwidget:disable_updates()
        end

        QuicksettingsPopup:register_bar(bar)
        QuicksettingsPopup:show_trigger()

        return QuicksettingsPopup
    end
}

return setmetatable(M, {__call = M.init})
