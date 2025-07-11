-- This module exists, so every ui element that needs to spawn
-- windows can register them here, windows will be either added
-- for each screen or for the primary screen.
--
-- So this is basically a window manager that manages the windows of
-- my window manager widgets... if i still smoked weed that would
-- sound deep i guess
--
-- main idea with the building and destroying of windows stolen from
-- kotontrions dots

local lgi = require "lgi"
local Gdk = lgi.require("Gdk")
local GLib = lgi.require("GLib")
local Application = require("astal.gtk3.app")

local insert = table.insert

local helpers = require("ui.helpers")

local P = {
    on_primary = {},
    on_all = {},
    windows = {}
}

P.on_mon_added = function(display, monitor)
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 100, function()
        -- this is used in a timeout_add call, so true if it needs to continue
        local model = monitor:get_model()
        if model == nil then
            return GLib.SOURCE_CONTINUE
        end

        helpers.log("new monitor: " .. model .. " on " .. display:get_name())
        for _, func in pairs(P.on_all) do
            func(monitor)
        end

        local primary = display:get_primary_monitor()
        if primary and primary == monitor then
            for _, func in pairs(P.on_primary) do
                func(monitor)
            end
        end

        return GLib.SOURCE_REMOVE
    end)
end

P.on_mon_removed = function(display, monitor)
    -- remove all windows associated with that monitor
    helpers.log("monitor removed: " .. monitor:get_model() .. " on " .. display:get_name())
    for _, window in pairs(Application:get_windows()) do
        if window.gdkmonitor == monitor then
            Application:remove_window(window)
        end
    end
end

local M = {}

---@param func function Function that accepts the monitor id as first argument
M.add_for_primary = function(func)
    insert(P.on_primary, func)
    local monitor = P.display:get_primary_monitor()
    func(monitor)
end

---@param func function Function that accepts the monitor id as first argument
M.add_for_all = function(func)
    insert(P.on_all, func)
    for i = 0, P.display:get_n_monitors() do
        local monitor = P.display:get_monitor(i)
        if monitor then func(monitor) end
    end
end

P.display_setup = function(manager, _)
    -- check if display available
    if #manager:list_displays() > 0 then
        P.display = manager:get_default_display()
        P.display.on_monitor_added = P.on_mon_added
        P.display.on_monitor_removed = P.on_mon_removed
    end
end

-- start managing all the windows and listening to changes on the GDK
-- DisplayManager
M.start_manage = function()
    P.manager = Gdk.DisplayManager.get()
    -- if the process is somehow still alive after the compositor/wm
    -- restarts, then we are going to get the next Display here
    P.manager.on_display_opened = P.display_setup
    P.manager.on_notify["default-display"] = P.display_setup
    -- start stuff up
    P.display_setup(P.manager, nil)
end

-- restarts all the windows
M.restart = function()
    -- remove windows
    for _, window in pairs(Application:get_windows()) do
        window:close()
        Application:remove_window(window)
    end

    -- spawn new ones
    for _, func in pairs(P.on_all) do
        for i = 0, P.display:get_n_monitors() do
            local monitor = P.display:get_monitor(i)
            if monitor then func(monitor) end
        end
    end
    local primary = P.display:get_primary_monitor()
    if primary then
        for _, func in pairs(P.on_primary) do
            func(primary)
        end
    end
end

-- open a window with CLASSNAME on GDKMONITOR
-- returns true if successful, otherwise false
M.open_win_on_gdkmonitor = function(gdkmonitor, classname)
    for _, window in pairs(Application:get_windows()) do
        if window.gdkmonitor == gdkmonitor and window.class_name == classname then
            window.visible = true
            return true
        end
    end
    return false
end

-- open a window with CLASSNAME on MONITOR
-- returns true if successful, otherwise false
M.open_win_on_monitor = function(monitor, classname)
    for _, window in pairs(Application:get_windows()) do
        if window.monitor == monitor and window.class_name == classname then
            window.visible = true
            return true
        end
    end
    return false
end

-- close a window with CLASSNAME on GDKMONITOR
-- returns true if successful, otherwise false
M.close_win_on_gdkmonitor = function(gdkmonitor, classname)
    for _, window in pairs(Application:get_windows()) do
        if window.gdkmonitor == gdkmonitor and window.class_name == classname then
            window.visible = false
            return true
        end
    end
    return false
end

-- close a window with CLASSNAME on MONITOR
-- returns true if successful, otherwise false
M.close_win_on_monitor = function(monitor, classname)
    for _, window in pairs(Application:get_windows()) do
        if window.monitor == monitor and window.class_name == classname then
            window.visible = false
            return true
        end
    end
    return false
end

return M
