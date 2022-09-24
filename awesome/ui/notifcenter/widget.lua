local wibox = require "wibox"
local awful = require "awful"
local naughty = require "naughty"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local gears = require "gears"
local helpers = require "helpers"

local iconsdir = gears.filesystem.get_configuration_dir() .. "assets/titlebarbuttons/"
local mat_icons = gears.filesystem.get_configuration_dir() .. "assets/materialicons/"

local recycler = require "plugins.awesome-widgets.recycler"
local rubato = require "plugins.rubato"

local function bar_indic_notif()
    require("ui.bar.bar").notifcenter_filled()
end

local function bar_indic_no_notif()
    require("ui.bar.bar").notifcenter_cleared()
end

local notifications
local function cross_enter (self, _)
    self:get_children_by_id('remove')[1]:set_image(gears.color.recolor_image(iconsdir .. "close.svg", beautiful.red))
end
local function cross_leave (self, _)
    self:get_children_by_id('remove')[1]:set_image(gears.color.recolor_image(iconsdir .. "close.svg", beautiful.fg_normal))
end



local notifctl = require "ui.notifications"
local template = {
    widget = wibox.container.background,
    bg = beautiful.bg_focus,
    {
        widget = wibox.container.constraint,
        width = dpi(400),
        strategy = 'max',
        {
            layout = wibox.layout.fixed.vertical,
            {
                widget = wibox.container.background,
                bg = beautiful.bg_focus_dark,
                fg = beautiful.fg_focus,
                {
                    widget = wibox.container.margin,
                    margins = dpi(5),
                    {
                        layout = wibox.layout.fixed.horizontal,
                        {
                            id = 'appname',
                            widget = wibox.widget.textbox,
                            font = beautiful.font_bold .. " 11",
                        },
                        {
                            widget = wibox.container.place,
                            fill_horizontal = true,
                            halign = 'right',
                            valign = 'center',
                            {
                                id = 'remove',
                                widget = wibox.widget.imagebox,
                                forced_height = beautiful.get_font_height(beautiful.font_bold .. " 11")/2,
                                forced_width = beautiful.get_font_height(beautiful.font_bold .. " 11"),
                            }
                        }
                    }
                }
            },
            {
                widget = wibox.container.margin,
                margins = dpi(5),
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = dpi(5),
                    {
                        widget = wibox.container.place,
                        valign = 'center',
                        {
                            id = 'icon',
                            widget = wibox.widget.imagebox,
                            resize = true,
                            forced_width = 0,
                            forced_height = 0,
                            clip_shape = beautiful.theme_shape
                        }
                    },
                    {
                        widget = wibox.container.place,
                        valign = 'top',
                        {
                            layout = wibox.layout.fixed.vertical,
                            spacing = dpi(5),
                            {
                                id = 'title',
                                widget = wibox.widget.textbox,
                                font = beautiful.font_bold .. " 11",
                            },
                            {
                                id = 'text',
                                widget = wibox.widget.textbox,
                                font = beautiful.font_thin .. " 11",
                            }
                        }
                    }
                }
            }
        }
    }
}

notifications = recycler(
    function()
        template.shape = beautiful.theme_shape
        local w = wibox.widget(template)
        function w:populate(n)
            self:get_children_by_id('remove')[1]:set_image(gears.color.recolor_image(iconsdir .. "close.svg", beautiful.fg_normal))
            self:get_children_by_id('remove')[1]:connect_signal("mouse::enter", function() cross_enter(w) end)
            self:get_children_by_id('remove')[1]:connect_signal("mouse::leave", function() cross_leave(w) end)
            self:get_children_by_id('title')[1].text = n.title
            self:get_children_by_id('appname')[1].text = n.app_name
            self:get_children_by_id('text')[1].text = n.message
            if n.icon then
                self:get_children_by_id('icon')[1]:set_image(n.icon)
                self:get_children_by_id('icon')[1].forced_height = dpi(40)
                self:get_children_by_id('icon')[1].forced_width = dpi(40)
            end
            self:get_children_by_id('remove')[1]:add_button(
                awful.button {
                    modifiers = {},
                    button = 1,
                    on_press = function ()
                        self:get_children_by_id('remove')[1]:disconnect_signal("mouse::enter", cross_enter)
                        self:get_children_by_id('remove')[1]:disconnect_signal("mouse::leave", cross_leave)
                        notifications:remove(self)
                        if #notifications:get_children() == 0 then bar_indic_no_notif() end
                        collectgarbage("collect")
                    end
                }
            )
        end
        return w
    end,
    {
        padx = 0,
        pady = 0,
        spacing = dpi(5),
        rubato_lib = rubato,
        pos_const = function ()
            return rubato.timed { duration = 0.1, intro = 0.2, prop_intro = true, rate = 60, easing = rubato.quadratic }
        end,
        inout_const = function ()
            return rubato.timed { duration = 0.1, intro = 0.04, rate = 60 }
        end
    }
)


local notifs_active = true

local notifbox
notifbox = wibox.widget { --empty because it will be filled with the update function
    layout = wibox.layout.fixed.vertical,
    spacing = dpi(5),
    {
        layout = wibox.layout.align.horizontal,
        expand = 'inside',
        {
            id = 'toggle_dnd_bg',
            widget = wibox.container.background,
            forced_height = beautiful.get_font_height(beautiful.font .. " 11"),
            bg = beautiful.bg_focus_dark,
            shape = beautiful.theme_shape,
            buttons = awful.button {
                modifiers = {},
                button = 1,
                on_press = function ()
                    notifs_active = not notifs_active
                    if notifs_active == true then notifctl.enable_notifs() else notifctl.disable_notifs() end
                    notifbox:get_children_by_id('toggle_dnd')[1]:set_image(notifs_active
                        and gears.color.recolor_image(mat_icons .. "notifications_active.svg", beautiful.fg_focus)
                        or gears.color.recolor_image(mat_icons .. "notifications_off.svg", beautiful.fg_focus)
                    )
                end
            },
            {
                widget = wibox.container.margin,
                margins = dpi(5),
                {
                    id = 'toggle_dnd',
                    widget = wibox.widget.imagebox,
                    forced_width = beautiful.get_font_height(beautiful.font .. " 11"),
                    image = gears.color.recolor_image(mat_icons .. "notifications_active.svg", beautiful.fg_focus),
                    resize = true,
                },
            }

        },
        {
            widget = wibox.container.margin,
            margins = {
                left = dpi(5),
                right = dpi(5)
    },
            {
                widget = wibox.container.background,
                forced_height = beautiful.get_font_height(beautiful.font_bold .. " 11") + dpi(10),
                bg = beautiful.bg_focus_dark,
                shape = beautiful.theme_shape,
                {
                    widget = wibox.container.margin,
                    margins = dpi(5),
                    {
                        widget = wibox.container.place,
                        halign = 'center',
                        fill_horizontal = true,
                        {
                            widget = wibox.widget.textbox,
                            text = 'notifications',
                            font = beautiful.font_bold .. " 11"
                        }
                    },
                }
            }
        },
        {
            id = 'clear_button',
            widget = wibox.container.background,
            forced_height = beautiful.get_font_height(beautiful.font .. " 11"),
            bg = beautiful.bg_focus_dark,
            shape = beautiful.theme_shape,
            buttons = awful.button {
                modifiers = {},
                button = 1,
                on_press = function ()
                    notifications:set_children() --clears
                    bar_indic_no_notif()
                end
            },
            {
                widget = wibox.container.margin,
                margins = dpi(5),
                {
                    widget = wibox.widget.imagebox,
                    forced_width = beautiful.get_font_height(beautiful.font .. " 11"),
                    image = gears.color.recolor_image(mat_icons .. "clear_all.svg", beautiful.fg_focus),
                    resize = true,
                },
            }
        }
    },
    notifications
}
helpers.pointer_on_focus(notifbox:get_children_by_id('clear_button')[1])
helpers.pointer_on_focus(notifbox:get_children_by_id('toggle_dnd_bg')[1])

local blacklisted_appnames = { "Spotify", "NetworkManager" }
local blacklisted_titles = { "Launching Application", "battery low!" }

local function check_list (n)
    for _, an in ipairs(blacklisted_appnames) do
        if an == n.app_name then return true end
    end
    for _, nt in ipairs(blacklisted_titles) do
        if nt == n.title then return true end
    end
    return false
end

naughty.connect_signal("request::display", function(n)
    if not check_list(n) then --ignore some notifications
        notifications:add_at(1,n)
        bar_indic_notif()
    end
end)

client.connect_signal("property::active", function (c)
    --most apps report their name via class so that should be alright
    if #notifications:get_children() == 0 then return end

    local cname = string.lower(c.class)
    local notscopy = notifications:get_children()
    for _, entry in pairs(notscopy) do
        if string.lower(entry:get_children_by_id('appname')[1].text) == cname then
            notifications:remove(entry)
        end
    end

    if #notifications:get_children() == 0 then bar_indic_no_notif() end

end)

return notifbox
