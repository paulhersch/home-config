local wibox = require "wibox"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local gears = require "gears"
local awful = require "awful"

local mpc = require "plugins.mpc"
local connection

local iconsdir	= gears.filesystem.get_configuration_dir() .. "assets/materialicons/"

local icons_for_state = {
    stop = gears.color.recolor_image(iconsdir .. "play.svg", beautiful.fg_focus),
    pause = gears.color.recolor_image(iconsdir .. "play.svg", beautiful.fg_focus),
    play = gears.color.recolor_image(iconsdir .. "pause.svg", beautiful.fg_focus)
}

local function create(base_box)
    local playerwidget = wibox.widget {
        widget = wibox.container.background,
        forced_width = dpi(300),
        bg = beautiful.bg_focus_dark,
        fg = beautiful.fg_normal,
        shape = beautiful.rounded_rect,
        {
            widget = wibox.container.margin,
            margins = dpi(5),
            {
                widget = wibox.container.margin,
                margins = dpi(5),
                {
                    layout = wibox.layout.fixed.vertical,
                    spacing = dpi(5),
                    {
                        layout = wibox.layout.fixed.vertical,
                        spacing = dpi(5),
                        {
                            widget = wibox.container.background,
                            fg = beautiful.blue,
                            {
                                id = 'title',
                                widget = wibox.widget.textbox,
                                font = beautiful.font_bold .. " 11",
                                halign = 'center',
                                forced_height = beautiful.get_font_height(beautiful.font_bold .. " 11"),
                                text = "nothing playing"
                            }
                        },
                        {
                            id = 'artist',
                            widget = wibox.widget.textbox,
                            font = beautiful.font_thin .. " 9",
                            halign = 'center',
                            forced_height = beautiful.get_font_height(beautiful.font_thin .. " 9"),
                            text = "nothing playing"
                        }
                    },
                    {
                        widget = wibox.container.place,
                        valign = 'bottom',
                        fill_vertical = true,
                        {
                            layout = wibox.layout.flex.horizontal,
                            forced_width = dpi(70),
                            forced_height = dpi(20),
                            {
                                id = 'bg',
                                widget = wibox.container.background,
                                shape = beautiful.theme_shape,
                                bg = beautiful.bg_focus_dark,
                                {
                                    widget = wibox.container.place,
                                    halign = 'center',
                                    valign = 'center',
                                    {
                                        widget = wibox.widget.imagebox,
                                        image = gears.color.recolor_image(iconsdir .. "previous.svg", beautiful.fg_normal),
                                        buttons	= awful.button({}, 1, function() connection:send("previous") end),
                                    }
                                }
                            },
                            {
                                id = 'bg',
                                widget = wibox.container.background,
                                shape = beautiful.theme_shape,
                                bg = beautiful.bg_focus_dark,
                                {
                                    widget = wibox.container.place,
                                    halign = 'center',
                                    valign = 'center',
                                    {
                                        id = 'play_pause',
                                        widget = wibox.widget.imagebox,
                                        image = gears.color.recolor_image(iconsdir .. "pause.svg", beautiful.fg_normal),
                                        buttons	= awful.button({}, 1, function() connection:toggle_play() end),
                                    }
                                }
                            },
                            {
                                id = 'bg',
                                widget = wibox.container.background,
                                shape = beautiful.theme_shape,
                                bg = beautiful.bg_focus_dark,
                                {
                                    widget = wibox.container.place,
                                    halign = 'center',
                                    valign = 'center',
                                    {
                                        widget = wibox.widget.imagebox,
                                        image = gears.color.recolor_image(iconsdir .. "next.svg", beautiful.fg_normal),
                                        buttons	= awful.button({}, 1, function() connection:send("next") end),
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    local function error_handler(err)
        --mpd_widget:set_text("Error: " .. tostring(err))
        -- Try a reconnect soon-ish
        gears.timer.start_new(10, function()
            connection:send("ping")
        end)
        error("error " .. tostring(err) .. " occured, keep calm i already tried to reconnect")
    end
    connection = mpc.new(nil, nil, nil, error_handler,
        "status", function(_, result)
            pcall(function()
                playerwidget:get_children_by_id('play_pause')[1].image = icons_for_state[result.state]
            end)
        end,
        "currentsong", function(_, result)
            pcall(function ()
                playerwidget:get_children_by_id('title')[1]:set_markup_silently(result.title)
                playerwidget:get_children_by_id('artist')[1]:set_markup_silently(result.artist)
            end)
    end)

    --this handles cursor change and bg highlighting for the imageboxes with play and pause
    for _,w in ipairs(playerwidget:get_children_by_id('bg')) do
        require("helpers").pointer_on_focus(w)
        w:connect_signal("mouse::enter", function (self)
            self.bg = beautiful.bg_focus
        end)
        w:connect_signal("mouse::leave", function (self)
            self.bg = beautiful.bg_focus_dark
        end)
    end

    return playerwidget
end

return {
	create = create
}
