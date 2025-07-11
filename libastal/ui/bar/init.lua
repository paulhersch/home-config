local lgi = require("lgi")
local AstalRiver = lgi.require("AstalRiver")
local GLib = lgi.require("GLib")
local Tray = lgi.require("AstalTray")
local IO = lgi.require("AstalIO")

local Astal = require("astal")
local App = require("astal.gtk3.app")
local Widget = require "astal.gtk3.widget"
local Anchor = require("astal.gtk3").Astal.WindowAnchor
local Variable = require("astal.variable")

local windowmanager = require "ui.windowmanagement"

-- popups
local messages = require "ui.bar.popups.messages"

local M = {}
local P = {}

--
-- Variables and Helper functions for Bar Modules
--

local _time_state = Variable(""):poll(
    3000,
    function() return GLib.DateTime.new_now_local():format("%H:%M - %A %e.") end
)

local _tray_service = Tray.get_default()

-- analogous to how the keybinds are defined
local _river_tags = {}
for i = 1, 9 do
    local tagid = bit.lshift(1, i - 1)
    table.insert(_river_tags, tagid)
end

-- find river output from gdkmonitor
local function _find_output(river, gdkmonitor)
    -- only one -> must be it
    if #river:get_outputs() == 1 then
        return river:get_outputs()[1]
    else
        for _, output in pairs(river:get_outputs()) do
            -- match by coordinates
            if output:get_x() == gdkmonitor.x and output:get_y() == gdkmonitor.y then
                return output
            end
        end
    end
end

--
-- Bar Modules
--

P.Time = function()
    return Widget.Label {
        label = _time_state(),
        expand = false
    }
end

-- output is of type AstalRiver.Output
P.River_Tags = function(output)
    local children = {}
    for index, id in ipairs(_river_tags) do
        table.insert(children, Widget.Button {
            on_click = function() IO.Process.exec("riverctl set-focused-tags " .. id, nil) end,
            setup = function(widget)
                local function set_color()
                    local selected = output.focused_tags
                    local occupied = output.occupied_tags
                    if bit.band(selected, id) ~= 0 then
                        widget.css = "color: @theme_selected_bg_color;"
                    elseif bit.band(occupied, id) ~= 0 then
                        widget.css = "color: @theme_fg_color;"
                    else
                        widget.css = "color: @bg2;"
                    end
                end
                function output:on_notify(pspec, _)
                    if pspec.name == "occupied-tags" or pspec.name == "focused-tags" then
                        set_color()
                    end
                end

                -- init
                set_color()
            end,
            class_name = "panel-tags--button",
            Widget.Label {
                label = tostring(index)
            }
        })
    end
    return Widget.Box {
        children = children
    }
end

P.River_Mode = function(river)
    -- 
    return Astal.bind(river, "mode"):as(function(mode)
        if mode == "resize" then
            return Widget.Icon {
                icon = "view-restore-symbolic",
                pixel_size = 24
            }
        end
        return nil
    end)
end

P.Tray = function(items)
    local children = {}
    for _, item in pairs(items) do
        if item.title then
            table.insert(children, Widget.MenuButton {
                class_name = "panel-tray--button",
                tooltip_markup = Astal.bind(item, "tooltip_markup"),
                use_popover = false,
                menu_model = Astal.bind(item, "menu-model"),
                action_group = Astal.bind(item, "action-group"):as(
                    function(ag) return { "dbusmenu", ag } end
                ),
                Widget.Icon {
                    gicon = Astal.bind(item, "gicon"),
                },
            })
        end
    end
    return children
end

---@param popups table<number, PopupBase>
P.Dynamic = function(popups, gdkmonitor)
    local children = {}

    -- print("dynamic creation")
    -- print(#popups)

    for _, p in pairs(popups) do
        -- print(p._class_name)
        local spawner_widget = p:get_spawner(gdkmonitor)
        table.insert(children, spawner_widget)
    end
    return children
end

P.create_bar = function(gdkmonitor)
    local river = AstalRiver.get_default()
    local output_on_gdkmonitor = _find_output(river, gdkmonitor)

    local box = Widget.CenterBox {
        class_name = "panel--main",
        spacing = 10,
        start_widget = Widget.Box {
            halign = "START",
            spacing = 5,
            Widget.Box {
                class_name = "panel--group",
                P.River_Tags(output_on_gdkmonitor)
            },
            P.River_Mode(river)
        },
        center_widget = Widget.Box {},
        end_widget = Widget.Box {
            halign = "END",
            Widget.Box {
                class_name = "panel--group",
                Astal.bind(_tray_service, "items"):as(P.Tray),
            },
            Widget.Box {
                class_name = "panel--group",
                P.Time()
            },
            -- openers
            Widget.Box {
                class_name = "panel--group",
                messages:get_spawner(gdkmonitor)
            }
        }
    }

    Widget.Window {
        class_name = "panel--window",
        visible = true,
        gdkmonitor = gdkmonitor,
        layer = 2,
        exclusivity = 1,
        anchor = Anchor.LEFT + Anchor.TOP + Anchor.RIGHT,
        setup = function(self)
            App:add_window(self)
        end,
        box
    }
end

-- i think i am too stupid but the register thing results in the variable binding not really doing
-- anything inside the bar setup function
-- ---@param Object PopupBase
-- M.register_popup = function(Object)
--     local copy = {}
--     for _, p in pairs(P.registered_popups:get()) do
--         table.insert(copy, p)
--     end
--     table.insert(copy, Object)
--     P.registered_popups:set(copy)
--
--     print("registered popup " .. Object._class_name .. " in bar")
-- end
--
-- ---@param Object PopupBase
-- M.remove_popup = function(Object)
--     local copy = {}
--     for _, p in pairs(P.registered_popups:get()) do
--         table.insert(copy, p)
--     end
--     for index, obj in pairs(copy) do
--         if obj == Object then
--             table.remove(copy, index)
--             P.registered_popups:set(copy)
--             print("removed popup " .. Object._class_name .. " in bar")
--             return
--         end
--     end
-- end

-- register in window manager
M.setup = function()
    -- only add window if river is used, i use waybar for sway
    if AstalRiver.get_default() == nil then
        return
    end
    windowmanager.add_for_all(P.create_bar)
    print("bar initialised")
end

return M
