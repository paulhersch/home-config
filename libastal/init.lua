-- setup loader
local currentfile = debug.getinfo(1).source:match(".*/"):sub(2)
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

Application:start {
    instance_name = "astal",
    main = function()
        require "osds"
    end,
    request_handler = function(request, res)
        res("hi")
    end
}
