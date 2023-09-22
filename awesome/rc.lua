local gears = require("gears")
local awful = require("awful")
local settings = require("settings")

awful.mouse.snap.edge_enabled = false
awful.mouse.snap.client_enabled = false

awesome.set_preferred_icon_size(128)

settings.set_defaults {
    notifications = {
        dnd = false,
        silent = false
    },
    weather = {
        lon = 0,
        len = 0,
        units = "metric",
        apikey = "123456"
    },
    modkey = "Mod1",
    terminal = "alacritty",
    filemanager = "nemo"
}

settings.load()
awesome.connect_signal("exit", function ()
    settings.save()
end)

require ("windowmanagement")
require ("ui")

-- Autostart {{{
awful.spawn("nm-applet")
awful.spawn("blueman-applet")
awful.spawn("xfce4-clipman")
awful.spawn("redshift -O 5300K -P")
-- deamon flag makes picom not send some random xlib error messages
awful.spawn("picom --config " .. gears.filesystem.get_configuration_dir() .. "/configs/picom.conf --daemon")
-- }}}
