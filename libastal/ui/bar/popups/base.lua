local Widget = require "astal.gtk3.widget"
local App = require("astal.gtk3.app")

local Windowmanager = require "ui.windowmanagement"
-- local Bar = require "ui.bar.init"

-- holds references to widgets that have been constructed
local CreatedWidgets = {}

local M = {}

-- Template to create widgets and windows for bar popups
-- automagically does the handling of opening and closing
-- windows, even of other open windows and also registers
-- itself in the bar
---@param class_name string Class the Window should have, ideally has an associated css class
---@param anchor Astal.WindowAnchor Anchor for this window. When Anchors are shared, all other windows will be closed before the one for this object will be opened
---@param widget_func function Function without argument that creates the widget used for this objects window
---@param icon string Icon Name or path to image that will be used as icon for the opener
function M.create_object(
    class_name,
    widget_func,
    anchor,
    icon,
    margin
)
    ---@class PopupBase
    ---
    ---@field _class_name string Name of the windows css class
    ---@field _anchor Astal.WindowAnchor Anchor of the window
    ---@field _icon string Icon name or path to image for the openers' icon
    local PopupBase = {
        ---@private
        _class_name = class_name,
        ---@private
        _anchor = anchor,
        ---@private
        _icon = icon,
        ---@private
        _opened = false
    }

    if not CreatedWidgets[anchor] then CreatedWidgets[anchor] = {} end
    table.insert(CreatedWidgets[anchor], PopupBase)

    --
    -- functions on Object
    --

    -- close the window for this object
    ---@param gdkmonitor Gdk.Monitor monitor to close the window on
    function PopupBase:close(gdkmonitor)
        Windowmanager.close_win_on_gdkmonitor(gdkmonitor, self._class_name)
        self._opened = false
    end

    -- open the window
    ---@param gdkmonitor Gdk.Monitor monitor to open the window on
    function PopupBase:open(gdkmonitor)
        for _, widget in pairs(CreatedWidgets[anchor]) do
            if widget ~= PopupBase then
                widget:close()
            end
        end
        Windowmanager.open_win_on_gdkmonitor(gdkmonitor, self._class_name)
        self._opened = true
    end

    -- create widget that will open the window for this Object
    ---@param gdkmonitor Gdk.Monitor monitor to create opener for
    function PopupBase:get_spawner(gdkmonitor)
        return Widget.Button {
            class_name = "panel-popup-opener--button",
            on_clicked = function()
                if self._opened then
                    self:close(gdkmonitor)
                else
                    self:open(gdkmonitor)
                end
            end,
            Widget.Icon {
                class_name = "panel-popup-opener--icon",
                icon = self._icon,
            }
        }
    end

    --
    -- Window spawner function
    --
    ---@param gdkmonitor Gdk.Monitor monitor to spawn window on
    function PopupBase:_spawn_window(gdkmonitor)
        Widget.Window {
            class_name = self._class_name,
            visible = false,
            gdkmonitor = gdkmonitor,
            layer = 2,
            exclusivity = 1,
            margin = margin,
            anchor = self._anchor,
            setup = function(window)
                App:add_window(window)
            end,
            widget_func()
        }
    end

    Windowmanager.add_for_all(function(mon) PopupBase:_spawn_window(mon) end)

    return PopupBase
end

return M
