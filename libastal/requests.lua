local M = {}
local P = {}

local Gio = require("lgi").require("Gio")
local gfs = require("gears.filestystem")

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

---@class requestsInit
---@field toplevel string path to the toplevel folder of the libastal config
---@field mainloop function main loop init (to rerun after) cache wipe

---@param args requestsInit arguments
M.init = function(args)
    P._toplevel = args.toplevel
    P._main = args.mainloop
    print("requests reinitialised")
end

M.handle_request = function(request, respond)
    local cmd = {}
    for w in string.gmatch(request, "%a+") do
        table.insert(cmd, w)
    end

    if P[cmd[1]] then
        local subcmd = table.remove(cmd, 1)
        P[subcmd](respond, cmd)
    else
        print(string.format("Request command %s not available", cmd[1]))
    end
end

return M
