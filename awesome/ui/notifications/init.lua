local naughty = require("naughty")
local beautiful = require("beautiful")
local wibox = require("wibox")
local awful = require("awful")
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")

NOTIFCENTER_DISPLAY = true
NOTIFCENTER_PLAYSOUND = true

local notifobject = wibox.widget.base.make_widget()

local function show_notifs ()
    NOTIFCENTER_DISPLAY = true
    notifobject:emit_signal("display::enabled")
    if NOTIFCENTER_PLAYSOUND then
        notifobject:emit_signal("sound::enabled")
    else
        notifobject:emit_signal("sound::disabled")
    end
end

local function hide_notifs ()
    NOTIFCENTER_DISPLAY = false
    notifobject:emit_signal("display::disabled")
    notifobject:emit_signal("sound::disabled")
end

local function mute_notifs ()
    NOTIFCENTER_PLAYSOUND = false
    notifobject:emit_signal("sound::disabled")
end

local function unmute_notifs ()
    NOTIFCENTER_PLAYSOUND = true
    notifobject:emit_signal("sound::enabled")
end

--[[n.actions_template = wibox.widget {
    widget = wibox.container.background,
    bg = beautiful.bg_focus,
    shape = beautiful.shape,
    {
        widget = wibox.container.margin,
        margins = dpi(5),
        {
            widget = wibox.widget.textbox,
            id = 'text_role',
            font = beautiful.font_thin .. " 10"
        }
    }
}

n.actions_template:connect_signal("mouse::enter",function ()
    n.actions_template.bg = beautiful.bg_focus_dark
end)
n.actions_template:connect_signal("mouse::leave",function ()
    n.actions_template.bg = beautiful.bg_focus
end)
helpers.pointer_on_focus(n.actions_template)
]]

local actionlist = require("naughty.list.actions")
local wicon      = require("naughty.widget.icon")
local wtitle     = require("naughty.widget.title")
local wmessage   = require("naughty.widget.message")

local template = {
    {
        {
            {
                widget = wibox.container.background,
--                bg = beautiful.bg_focus_dark,
                {
                    wtitle,
                    widget = wibox.container.margin,
                    margins = {
                        top = dpi(5),
                        left = dpi(5),
                        right = dpi(5)
                    }
                }
            },
            {
                {
                    {
                        {
                            {
                                {
                                    wicon,
                                    widget = wibox.container.background,
                                    shape = beautiful.theme_shape
                                },
                                widget = wibox.container.place,
                                valign = 'center'
                            },
                            {
                                widget = wibox.container.place,
                                valign = 'top',
                                wmessage,
                            },
                            spacing = dpi(5),
                            layout  = wibox.layout.fixed.horizontal,
                        },
                        widget = wibox.container.margin,
                        margins = dpi(5)
                    },
                    --{
                        --base_layout = {
                        --    layout = wibox.layout.flex.horizontal,
                        --    spacing = dpi(5)
                        --},
                        --widget_template = {
                        --
                        --},
                        --widget =
                        actionlist,
                    --},
                    layout  = wibox.layout.fixed.vertical,
                },
                id     = "background_role",
                widget = wibox.container.background,
            },
            spacing = dpi(5),
            layout  = wibox.layout.fixed.vertical,
        },
        widget = wibox.container.background,
        shape = beautiful.theme_shape,
        bg = beautiful.bg_focus_dark
    },
    widget = wibox.container.constraint,
    strategy = 'max',
    width = dpi(500)
}

local whitelist_titles = { "battery low!" }
local whitelist_programs = { }
local blacklist_sound_titles = { "Launching Application" }
local blacklist_sound_programs = { "NetworkManager", "Spotify" }

naughty.config.padding = dpi(50)
naughty.config.spacing = dpi(50)
naughty.config.defaults.position = "bottom_left"
naughty.config.defaults.border_width = 0

function whitelist_programs:check(n) --check_list(n.app_name, self) return false end
    for _, na in ipairs(self) do
        if na == n.app_name then return true end
    end
end

function whitelist_titles:check(n) --check_list(n.title, self) return false end
    for _, na in ipairs(self) do
        if na == n.title then return true end
    end
end

function blacklist_sound_programs:check(n)
    for _, na in ipairs(self) do
        if na == n.app_name then return true end
    end

end--check_list(n.app_name, blacklist_sound_programs) return false end

function blacklist_sound_titles:check(n) --check_list(n.title, blacklist_sound_titles) return false end
    for _, na in ipairs(self) do
        if na == n.title then return true end
    end
end

local function init ()
    naughty.connect_signal("request::display", function (notif)
        if NOTIFCENTER_DISPLAY
            or whitelist_programs:check(notif)
            or whitelist_titles:check(notif)
            then
            naughty.layout.box {
                notification = notif,
                widget_template = template,
                shape = beautiful.theme_shape,
                padding = dpi(10),
                spacing = dpi(12)
            }
            if NOTIFCENTER_PLAYSOUND then
                if (not (blacklist_sound_titles:check(notif) or blacklist_sound_programs:check(notif))) then
                    awful.spawn("play -v 0.2 " .. gears.filesystem.get_configuration_dir() .. "assets/sounds/notif.mp3")
                end
            end
        end
    end)
end

return {
    enable_notifs = show_notifs,
    disable_notifs = hide_notifs,
    enable_sound = unmute_notifs,
    disable_sound = mute_notifs,
    init = init,
    signals = notifobject
}
