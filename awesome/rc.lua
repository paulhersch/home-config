local gears = require("gears")
local awful = require("awful")
local settings = require("settings")

awful.mouse.snap.edge_enabled = false
awful.mouse.snap.client_enabled = false

awesome.set_preferred_icon_size(128)

settings.load()
awesome.connect_signal("exit", function ()
    settings.save()
end)

require ("ui")
-- currently required due to windowmanagement loading keybinds that open
-- UI stuff (TODO: clean up and load open binds after init)
require ("windowmanagement")

-- Autostart {{{
awful.spawn("nm-applet")
awful.spawn("blueman-applet")
awful.spawn("xfce4-clipman")
awful.spawn("redshift -O 5300K -P")
awful.spawn("picom --config " .. gears.filesystem.get_configuration_dir() .. "/configs/picom.conf")
-- }}}
