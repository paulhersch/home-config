local lgi = require "lgi"
local GLib = lgi.require("GLib")

-- local Astal = lgi.require("Astal")
local App = require("astal.gtk3.app")
local Widget = require("astal.gtk3.widget")
local Anchor = require("astal.gtk3").Astal.WindowAnchor

local window_manager = require("ui.windowmanagement")
local notifservice = require("ui.services.notifications")

local M = {}

local default_layout = function(notification)
    local action_buttons = {}
    for _, action in pairs(notification.actions) do
        table.insert(action_buttons, Widget.Button {
            on_click = function()
                if action.id then
                    notification:invoke(action.id)
                end
            end,
            Widget.Label {
                label = action.label or "action"
            }
        })
    end

    return Widget.EventBox {
        on_click = function(_, _) -- (_, event)
            notification:dismiss()
            -- if e.button == Astal.MouseButton.PRIMARY then
            --     notification:dismiss()
            -- end
        end,
        Widget.Box {
            spacing = 5,
            vexpand = true,
            class_name = "notification",
            (notification.image or notification.app_icon ~= "") and Widget.Icon {
                class_name = "notification--icon",
                icon = notification.image or notification.app_icon,
                pixel_size = 64,
            } or nil,
            Widget.Box {
                vertical = true,
                spacing = 4,
                Widget.Label {
                    class_name = "notification--summary",
                    label = "<span size='large' style='italic'><b>" .. GLib.markup_escape_text(notification.summary, -1) .. "</b></span>",
                    xalign = 0,
                    wrap = false,
                    ellipsize = 3,
                    use_markup = true
                },
                Widget.Label {
                    class_name = "notification--body",
                    label = GLib.markup_escape_text(notification.body, -1),
                    xalign = 0,
                    wrap = true,
                    use_markup = true
                },
                #notification.actions > 0 and Widget.Box {
                    spacing = 3,
                    action_buttons
                }
            },
        }
    }
end

-- want to make sure this is run intentionally n stuff
M.setup = function()
    -- window spawner to be used
    local function window_setup(gdkmonitor)
        local box = Widget.Box {
            spacing = 10,
            valign = 2,
            vertical = true,
            expand = true,
            -- shorthand to bind to var value
            children = notifservice.shown(function(notifications)
                local children = {}
                for _, n in pairs(notifications) do
                    table.insert(children, default_layout(n))
                end
                return children
            end),
        }
        -- helpers.log("notifications set up on " .. gdkmonitor:get_model())
        Widget.Window {
            class_name = "notifications",
            visible = true,
            gdkmonitor = gdkmonitor,
            anchor = Anchor.LEFT + Anchor.BOTTOM,
            setup = function(self)
                App:add_window(self)
            end,
            box
        }
    end
    window_manager.add_for_all(window_setup)
end

return M
