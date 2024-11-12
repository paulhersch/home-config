local lgi = require "lgi"

local timeout = require("astal.time").timeout
local App = require("astal.gtk3.app")
local Widget = require("astal.gtk3.widget")
local Anchor = require("astal.gtk3").Astal.WindowAnchor
local Variable = require("astal.variable")
-- https://aylur.github.io/astal/guide/libraries/notifd
local Notifd = lgi.require("AstalNotifd")

local M = {}
local P = {
    notification_area = nil,
    box = nil,
    visible_notifications = {},
}

P.notif_data_to_widget = function(data)
    return Widget.Box {
        vertical = true,
        spacing = 5,
        children = {
            Widget.Label { label = data.summary },
            Widget.Label { label = data.body }
        }
    }
end

P.update_children = function()
    local children = {}
    for _, n in pairs(P.visible_notifications) do
        table.insert(children, P.notif_data_to_widget(n))
    end
    P.box:set_children(children)
end

M.setup = function()
    if P.box then
        P.box = nil
    end

    P.box = Widget.Box {
        spacing = 10,
        valign = 2,
        vertical = true,
        children = {}
    }

    -- insert notification into visible ones, when notification gets sent to dbus obj
    -- start timer and remove after 5 seconds
    local notifd = Notifd.get_default()
    notifd.on_notified = function(_, id)
        local notification = notifd:get_notification(id)
        table.insert(P.visible_notifications, notification)
        P.update_children()

        timeout(5000, function()
            for i, item in pairs(P.visible_notifications) do
                if item.id == id then
                    table.remove(P.visible_notifications, i)
                    break
                end
            end
            P.update_children()
        end)
    end

    if P.notification_area then
        P.notification_area = nil
    end
    -- setup Window
    P.notification_area = Widget.Window {
        visible = true,
        monitor = 0,
        anchor = Anchor.LEFT + Anchor.BOTTOM, -- + Anchor.TOP,
        P.box
    }
end

return M
