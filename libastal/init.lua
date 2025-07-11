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
local GLib = lgi.require("GLib")

-- main_loop can be passed to requests, so that requests will rerun it after a reload
local function main_loop()
    print("run main loop")
    require "requests".init {
        mainloop = main_loop,
        toplevel = currentfile
    }
    require "ui"
    print("setup complete")
    -- GLib.set_prgname("astal")
end

Application:start {
    instance_name = "astal",
    css = currentfile .. "/css/main.css",
    main = main_loop,
    client = function(request)
        -- new client started -> issue reload command on main instance
        print(request("reload"))
        Application:apply_css(currentfile .. "/css/main.css")
    end,
    request_handler = function(req, res)
        require("requests").handle_request(req, res)
    end
}
