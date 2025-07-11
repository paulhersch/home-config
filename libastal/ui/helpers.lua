local lgi = require "lgi"
local Gdk = lgi.require("Gdk")
local GLib = lgi.require("GLib")

local M = {}

M.log = function(msg)
    GLib.log_default_handler(nil, GLib.LogLevelFlags.LEVEL_MESSAGE, msg, nil)
end

return M
