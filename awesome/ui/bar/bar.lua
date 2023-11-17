local wibox	= require "wibox"
local awful	= require "awful"
local beautiful = require "beautiful"
local dpi	= beautiful.xresources.apply_dpi
local helpers	= require "helpers"

local container = require "ui.components.container"
local buttonify = container.button.buttonify

local LauncherPopup = require("ui.bar.popups.launcher")
local DatePopup = require("ui.bar.popups.date")
local QuicksettingsPopup = require("ui.bar.popups.quicksettings")
local WeatherPopup = require("ui.bar.popups.weather")

local P = {
    tagged_tag_col = beautiful.gray,
    default_tag_col = helpers.color.col_mix(beautiful.bg_1, beautiful.gray),
    tagnames = { "०", "१", "२", "३", "४", "५", "६", "७", "८", "९" },
}

P.init_taglist = function (s)
    return awful.widget.taglist {
        screen		= s,
        filter		= awful.widget.taglist.filter.all,
        layout 		= {
            layout = wibox.layout.flex.horizontal,
            spacing = dpi(5)
        },
        widget_template = {
            widget = wibox.container.background,
            id = 'bg',
            shape = beautiful.theme_shape,
            fg = beautiful.bg_2,
            bg = beautiful.bg_1,
            forced_width = dpi(20),
            forced_height = dpi(20),
            {
                {
                    widget = wibox.widget.textbox,
                    font = "Free Sans Bold" ,
                    halign = 'center',
                    id = 'index',
                    text = ' ',
                },
                widget = wibox.container.place,
                halign = 'center',
            },
            create_callback = function(self, t, _, _)
                buttonify({
                    widget = self
                })
                self:get_children_by_id("index")[1].text = P.tagnames[t.index]
                self:add_button(awful.button {
                    modifier = {},
                    button = awful.button.names.LEFT,
                    on_press = function ()
                        t:view_only()
                        self:draw_clicked()
                    end,
                })
                if t.selected then
                    self:get_children_by_id('bg')[1].fg = beautiful.blue
                    self:draw_clicked()
                else
                    self:get_children_by_id('bg')[1].fg = #t:clients() > 0 and P.tagged_tag_col or P.default_tag_col
                    self:draw_released()
                end
            end,
            update_callback = function (self, t, _, _)
                if t.selected then
                    self:draw_clicked()
                    self:get_children_by_id('bg')[1].fg = beautiful.blue
                else
                    self:draw_released()
                    self:get_children_by_id('bg')[1].fg = #t:clients() > 0 and P.tagged_tag_col or P.default_tag_col
                end
            end
        }
    }
end

P.init_tasklist = function (s)
    return awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = {
            awful.button({ }, 1, function (c)
                c:activate { context = "tasklist", action = "toggle_minimization" }
            end),
        },
        widget_template = {
            widget = wibox.container.background,
            {
                widget = wibox.container.constraint,
                width = dpi(120),
                strategy = "exact",
                {
                    widget = wibox.container.place,
                    halign = "center",
                    {
                        widget = wibox.container.margin,
                        margins = dpi(5),
                        {
                            id = "client_name",
                            widget = wibox.widget.textbox,
                        }
                    }
                }
            },
            create_callback = function (self, c)
                container.button.buttonify {
                    widget = self
                }
                c:connect_signal("property::active", function ()
                    if c.active then
                        self:draw_clicked()
                    else
                        self:draw_released()
                    end
                end)

                c:connect_signal("property::name", function ()
                    if c.name then
                        self:get_children_by_id('client_name')[1].text = c.name
                    end
                end)
                -- initial state
                if c.name then
                    self:get_children_by_id('client_name')[1].text = c.name
                end

                if c.active then
                    self:draw_clicked()
                else
                    self:draw_released()
                end
            end
        },
        layout = {
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(5)
        },
    }
end

local M = {}

M.init = function(s)

    s.taglist = P.init_taglist(s)
    s.tasklist = P.init_tasklist(s)
    local systray = s == screen.primary and wibox.widget {
        widget = wibox.container.background,
        bg = beautiful.bg_1,
        {
            widget = wibox.container.margin,
            margins = dpi(5),
            {
                widget = wibox.widget.systray,
                base_size = dpi(20),
            }
        }
    } or nil


    local bar_widget = wibox.widget {
        widget = wibox.container.margin,
        margins = dpi(5),
        {
            layout = wibox.layout.flex.horizontal,
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(5),
                {
                    layout = wibox.layout.fixed.horizontal,
                    id = "variable_left",
                    spacing = dpi(5)
                },
                {
                    widget = wibox.container.place,
                    halign = 'left',
                    valign = 'center',
                    fill_vertical = true,
                    s.taglist,
                },
            },
            {
                widget = wibox.container.place,
                halign = "center",
                s.tasklist
            },
            {
                widget = wibox.container.place,
                halign = 'right',
                valign = 'top',
                fill_horizontal = false,
                fill_vertical = true,
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = dpi(5),
                    systray,
                    {
                        id = "variable_right",
                        layout = wibox.layout.fixed.horizontal,
                        spacing = dpi(5),
                    }
                }
            },
        }
    }

    s.bar = awful.wibar {
        screen = s,
        position = "top",
        stretch = true,
        restrict_workarea = true,
        height = beautiful.wibar_height,
        ontop = true,
        widget = bar_widget
    }

    function s.bar:add_widget(widget, anchor)
        if anchor == "left" then
            s.bar:get_children_by_id("variable_left")[1]:add(widget)
        else if anchor == "right" then
                s.bar:get_children_by_id("variable_right")[1]:insert(1, widget)
            else
                error("anchor for :add_widget wasnt either of left or right")
            end
        end
    end

    function s.bar:remove_widget(widget, anchor)
        s.bar:get_children_by_id("variable_" .. anchor)[1]:remove_widgets(widget)
    end

    function s.bar:replace_widget(widget, widget2, anchor)
        s.bar:get_children_by_id("variable_" .. anchor)[1]:replace_widget(widget, widget2)
    end

    LauncherPopup.init(s.bar)
    QuicksettingsPopup.init(s.bar)
    DatePopup.init(s.bar)
    WeatherPopup.init(s.bar)

end

M.hide = function(s)
    s.bar.visible = false
end

M.show = function(s)
    s.bar.visible = true
end

return M
