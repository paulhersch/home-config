-- setup loader
local currentfile = debug.getinfo(1).source:match(".*/"):sub(2) -- directory of this file
package.path = package.path .. string.format(";%s?.lua;%s?/init.lua", currentfile, currentfile)

-- table unpack compat
if unpack then
    table.unpack = unpack
else
    unpack = table.unpack
end

-- start Astal App
local lgi = require "lgi"
local Application = require("astal.gtk3.app")

-- main_loop can be passed to requests, so that requests will rerun it after a reload
local function main_loop()
    print("restarting main loop")
    require "requests".init {
        mainloop = main_loop,
        toplevel = currentfile
    }
    require "ui"
    print("setup complete")
end

Application:start {
    instance_name = "astal",
    css = currentfile .. "/css/main.css",
    main = main_loop,
    -- client = function(request)
    --     -- new client started -> issue reload command on main instance
    --     -- that way lua libastal/init.lua can be called everytime instead
    --     -- of deciding whether to reload or start an instance
    --     print(request("reload"))
    -- end,
    request_handler = function(req, res)
        -- use require so that if require cache gets invalidated through update
        -- we can call the updated funcs
        -- this pattern will be used throughout the config
        require("requests").handle_request(req, res)
    end
}
