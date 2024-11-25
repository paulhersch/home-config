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
        class_name = "notification",
        children = {
            Widget.Label {
                label = data.summary,
                xalign = 0,
                wrap = false,
                -- truncate = "end",
            },
            Widget.Label {
                label = data.body,
                xalign = 0,
                wrap = true
            }
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

-- want to make sure this is run intentionally n stuff
M.setup = function()
    P.box = Widget.Box {
        spacing = 10,
        valign = 2,
        vertical = true,
        children = {},
    }

    -- insert notification into visible ones, when notification gets sent to dbus obj
    -- start timer and remove after 5 seconds
    P.notifd = Notifd.get_default()
    P.notifd.on_notified = function(_, id)
        local notification = P.notifd:get_notification(id)
        print("received notification with message: " .. notification.body)
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

    -- setup Window if does not exist
    P.notification_area = App:get_window("notifications")
    if not P.notification_area then
        P.notification_area = Widget.Window {
            name = "notifications",
            class_name = "popup--window",
            visible = true,
            monitor = 0,
            anchor = Anchor.LEFT + Anchor.BOTTOM,
            setup = function(self)
                App:add_window(self)
            end,
            P.box,
        }
    end
end

M.unload = function()
    App:remove_window(P.notification_area)
    -- set func to nil to stop receiving stuff
    -- should be handled by P = nil, but want to make sure it deletes the function
    P.notifd.on_notified = nil
    P.notifd:run_dispose()
    -- P.notifd:do_finalize()
    P = nil
end

return M
