local lgi = require("lgi")
local GLib = lgi.require("GLib")

local Widget = require "astal.gtk3.widget"
local Anchor = require("astal.gtk3").Astal.WindowAnchor

local notifications = require "ui.services.notifications"
local base = require "ui.bar.popups.base"

local M = {}

local function create_message_widget(message)
    return Widget.EventBox {
        on_click = function(_, _)
            notifications:delete_from_saved(message.id)
        end,
        Widget.Box {
            spacing = 5,
            class_name = "message-item",
            (message.image or message.app_icon ~= "") and Widget.Icon {
                class_name = "message-item--icon",
                icon = message.image or message.app_icon,
                pixel_size = 64,
            } or nil,
            Widget.Box {
                vertical = true,
                spacing = 4,
                Widget.Label {
                    class_name = "notification--summary",
                    label = "<span size='large' style='italic'><b>" .. GLib.markup_escape_text(message.summary, -1) .. "</b></span>",
                    xalign = 0,
                    wrap = false,
                    ellipsize = 3,
                    use_markup = true
                },
                Widget.Label {
                    class_name = "notification--body",
                    label = GLib.markup_escape_text(message.body, -1),
                    xalign = 0,
                    wrap = true,
                    use_markup = true
                },
            }
        }
    }
end

local function create_widget()
    return Widget.Box {
        class_name = "message-list",
        valign = 1,
        vertical = true,
        spacing = 5,
        homogeneous = false,
        vexpand = true,
        -- TODO: placeholder
        -- TODO: DND switch
        notifications.saved(function(messages)
            local children = {}
            for _, m in pairs(messages) do
                table.insert(children, 1, create_message_widget(m))
            end
            return children
        end)
    }
end

return base.create_object(
    "messages",
    create_widget,
    Anchor.RIGHT + Anchor.TOP,
    "mail-unread-symbolic",
    10
)
