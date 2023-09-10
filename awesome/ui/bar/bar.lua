local wibox	= require "wibox"
local awful	= require "awful"
local gears	= require "gears"
local beautiful = require "beautiful"
local cairo = require "lgi".cairo
local dpi	= beautiful.xresources.apply_dpi
local helpers	= require "helpers"
local container = require "ui.components.container"
local buttonify = container.buttonify

local LauncherPopup = require("ui.bar.popups.launcher")
local DatePopup = require("ui.bar.popups.date")
local QuicksettingsPopup = require("ui.bar.popups.quicksettings")

-- local pctl_indicator = wibox.widget
-- {
--     widget = wibox.widget.imagebox,
--     image = gears.color.recolor_image(gears.filesystem.get_configuration_dir() .. "assets/materialicons/music_note.svg", beautiful.fg_normal),
-- }
--
-- local notif_indicator = wibox.widget
-- {
-- 	id = 'notif_icon',
-- 	widget = wibox.widget.imagebox,
-- 	resize = true,
-- 	halign = 'center',
-- 	image = gears.color.recolor_image(gears.filesystem.get_configuration_dir() .. "assets/materialicons/forum.svg", beautiful.fg_normal),
-- }

local function init (s)
	local tagged_tag_col = beautiful.gray
    local default_tag_col = helpers.color.col_mix(beautiful.bg_focus_dark, beautiful.gray)
    local tagnames = { "०", "१", "२", "३", "४", "५", "६", "७", "८", "९" }
    s.taglist = awful.widget.taglist {
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
            fg = beautiful.bg_focus,
            bg = beautiful.bg_focus_dark,
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
                buttonify(self, {})
                self:get_children_by_id("index")[1].text = tagnames[t.index]
                self:add_button(awful.button {
                    modifier = {},
                    button = awful.button.names.LEFT,
                    on_press = function ()
                        t:view_only()
                        self:draw_clicked()
                    end,
                    -- on_release = function ()
                    --     self:draw_released()
                    -- end
                })
                self:get_children_by_id('bg')[1].fg = t.selected and beautiful.blue or (#t:clients() > 0 and tagged_tag_col or default_tag_col)
			end,
            update_callback = function (self, t, _, _)
                if t.selected then
                    self:draw_clicked()
                else
                    self:draw_released()
                end
                self:get_children_by_id('bg')[1].fg = t.selected and beautiful.blue or (#t:clients() > 0 and tagged_tag_col or default_tag_col)
            end
		}
	}

    local systray = s == screen.primary and wibox.widget {
        widget = wibox.container.background,
        bg = beautiful.bg_focus_dark,
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
        -- bgimage = function (_, cr, w, h)
        -- local pattern = cairo.Pattern.create_linear(0, 0, 0, h)
        -- pattern:add_color_stop_rgba(0, gears.color.parse_color(beautiful.bg_normal))
        -- pattern:add_color_stop_rgba(0.9, gears.color.parse_color(beautiful.bg_normal))
        -- pattern:add_color_stop_rgba(0.95, gears.color.parse_color(beautiful.bg_focus_dark))
        -- pattern:add_color_stop_rgba(1, gears.color.parse_color(beautiful.bg_focus))
        --
        -- cr:rectangle(0, 0, w, h)
        -- cr:set_source(pattern)
        -- cr:fill()
        -- cr:set_source_rgba(gears.color.parse_color(beautiful.bg_focus_dark))
        -- cr:set_line_width(dpi(5))
        -- cr:move_to(0,h)
        -- cr:line_to(w,h)
        -- cr:stroke()
        -- end,
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

end

local function hide(s)
	s.bar.visible = false
end

local function show(s)
	s.bar.visible = true
end

-- local function display_pending_notifs()
-- 	if not quicksettings_trigger:index(notif_indicator) then
-- 		quicksettings_trigger:insert(1, notif_indicator)
-- 	end
-- end
--
-- local function no_pending_notifs()
-- 	if quicksettings_trigger:index(notif_indicator) then
-- 		quicksettings_trigger:remove_widgets(notif_indicator)
-- 	end
-- end
--
-- local function pctl_song_active()
--     quicksettings_trigger:insert(1, pctl_indicator)
-- end
--
-- local function pctl_song_inactive()
--     quicksettings_trigger:remove_widgets(pctl_indicator)
-- end

return {
	init	= init,
	hide	= hide,
	show	= show,
    -- notifcenter_filled = display_pending_notifs,
    -- notifcenter_cleared = no_pending_notifs,
    -- pctl_active = pctl_song_active,
    -- pctl_inactive = pctl_song_inactive
}
