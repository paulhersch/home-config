local M = {}
local P = {}

local lgi = require("lgi")
local Gio = lgi.require("Gio")
local gfs = require("gears.filestystem")
local windowmanagement = require("ui.windowmanagement")

local App = require("astal.gtk3.app")

-- need to figure out the gobject destroying and finalizing stuff first
-- P.reload = function(respond, _)
--     -- collect files in config dir
--     local dir = Gio.File.new_for_path(P._toplevel)
--     local files = dir:enumerate_children("standard::*", 0)
--     local toplevel_items = {}
--     for file in function() return files:next_file() end do
--         local without_stuff = string.match(file:get_display_name(), "%a+")
--         table.insert(toplevel_items, without_stuff)
--     end
--
--     -- check for each item in require cache if it is a module
--     -- from the config
--     -- collect indices to remove in a list
--     to_unload = {}
--     for index, _ in pairs(package.loaded) do
--         for _, name in pairs(toplevel_items) do
--             if string.match(index, "^" .. name) then
--                 -- tell module to unload all data
--                 -- if index == toplevel name then we have reached the root
--                 -- unload if function exists
--                 if index == name and require(name)["unload"] then require(name).unload() end
--                 -- remove cache
--                 table.insert(to_unload, index)
--             end
--         end
--     end
--
--     for _, index in pairs(to_unload) do
--         package.loaded[index] = nil
--     end
--
--     P._main()
--     respond("reload done")
-- end
P.reload = function(respond, _)
    require("ui.windowmanagement").restart()
    require("ui.services.notifications"):clear()
    respond("restarted with fresh state")
end

P.list = function(respond, subcmds)
    local subcmd = #subcmds > 0 and subcmds[1] or nil
    if not subcmd then
        respond(
            "missing subcommand for list. available:\n"
            .. "  list"
        )
        return
    end

    if subcmd == "windows" then
        names = {}
        for _, window in pairs(App:get_windows()) do
            local name = (
                "  - "
                .. (window.class_name or "no class")
                .. " on "
                .. window.monitor
            )
            table.insert(names, name)
        end
        respond(table.concat(names, "\n"))
    else
        respond(
            "subcommand " .. subcmd .. " for list doesnt exist"
        )
    end
end

P.open = function(respond, subcmds)
    local subcmd = #subcmds > 0 and subcmds[1] or nil
    if not subcmd then
        respond("available subcmds for open: window")
    end

    if subcmd == "window" then
        if #subcmds < 3 then
            respond(
                "not enough args for open window, required: class name, monitor index\n"
                .. "subcommand: " .. table.concat(subcmds, " ")
            )
        end
        local window, monitor = subcmds[2], subcmds[3]
        local succ = windowmanagement.open_win_on_monitor(tonumber(monitor), window)
        if succ then
            respond("opened window " .. window .. " on monitor " .. monitor)
        else
            respond("failed to open window " .. window .. " on monitor " .. monitor)
        end
    else
        respond("subcmd " .. subcmd .. " not available.")
    end
end

P.close = function(respond, subcmds)
    local subcmd = #subcmds > 0 and subcmds[1] or nil
    if not subcmd then
        respond("available subcmds for open: window")
    end

    if subcmd == "window" then
        if #subcmds < 3 then
            respond(
                "not enough args for open window, required: class name, monitor index\n"
                .. "subcommand: " .. table.concat(subcmds, " ")
            )
        end
        local window, monitor = subcmds[2], subcmds[3]
        local succ = windowmanagement.close_win_on_monitor(tonumber(monitor), window)
        if succ then
            respond("opened window " .. window .. " on monitor " .. monitor)
        else
            respond("failed to open window " .. window .. " on monitor " .. monitor)
        end
    else
        respond("subcmd " .. subcmd .. " not available.")
    end
end

---@class requestsInit
---@field toplevel string path to the toplevel folder of the libastal config
---@field mainloop function main loop init (to rerun after) cache wipe

---@param args requestsInit arguments
M.init = function(args)
    P._toplevel = args.toplevel
    P._main = args.mainloop
    print("requests initialised")
end

M.handle_request = function(request, respond)
    local cmd = {}
    for w in string.gmatch(request, "%S+") do
        table.insert(cmd, w)
    end

    if P[cmd[1]] then
        local subcmd = table.remove(cmd, 1)
        P[subcmd](respond, cmd)
    else
        respond(string.format("Request command %s not available", cmd[1]))
    end
end

return M
