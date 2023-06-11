local wibox	= require "wibox"
local awful	= require "awful"
local gears	= require "gears"
local beautiful = require "beautiful"
local cairo = require "lgi".cairo
local dpi	= beautiful.xresources.apply_dpi
local helpers	= require "helpers"
local container = require "components.container"
local btn = container.button
local buttonify = container.buttonify

local battery   = require "ui.bar.widgets.battery".widget

local pctl_indicator = wibox.widget
{
    widget = wibox.widget.imagebox,
    image = gears.color.recolor_image(gears.filesystem.get_configuration_dir() .. "assets/materialicons/music_note.svg", beautiful.fg_normal),
}

local notif_indicator = wibox.widget
{
	id = 'notif_icon',
	widget = wibox.widget.imagebox,
	resize = true,
	halign = 'center',
	image = gears.color.recolor_image(gears.filesystem.get_configuration_dir() .. "assets/materialicons/forum.svg", beautiful.fg_normal),
}

local quicksettings_trigger = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    spacing = dpi(5),
    battery
}

local popups = {
	"menu",
	"quicksettings",
	"launcher"
}

local function hide_all_popups_on_screen(screen, override_shown)
	for _, p in ipairs(popups) do
		require("ui.bar.popups." .. p).hide(screen)
		if (override_shown) then screen[p .. "_stat"] = false end
	end
end

local buttons = {}
local btn_sgnl_trigger = wibox.widget.base.make_widget()
-- shortcut to wrap menu and quicksettings triggers (and also the "normal" widgets without popups, if popup_name is nil the popup wont be shown)
local function popup_button(widget, popup_name, screen)
    local button
    if popup_name ~= nil then
        button = btn({
            widget = widget,
            manual_draw = true,
            left = {
                on_click = function ()
                    if screen[popup_name .. "_stat"] then
                        require("ui.bar.popups." .. popup_name).hide(screen)
                        button:draw_released()
                    else
                        for _, p_name in ipairs(popups) do
                            if screen[p_name .. "_stat"] then
                                require("ui.bar.popups." .. p_name).hide(screen)
                                screen[p_name .. "_stat"] = false
                                --bad practice to use awesome in but i am extremely lazy
                                btn_sgnl_trigger:emit_signal(p_name .. "::unclick")
                            end
                        end
                        require("ui.bar.popups." .. popup_name).show(screen)
                        button:draw_clicked()
                    end
                    screen[popup_name .. "_stat"] = not screen[popup_name .. "_stat"]
                end
            }
        })
    else
        button = {
            widget = wibox.container.background,
            bg = beautiful.bg_focus_dark,
            shape = beautiful.theme_shape,
            {
                widget = wibox.container.margin,
                margins = dpi(5),
                widget
            }
		}
    end

    local templ = wibox.widget {
        widget = wibox.container.margin,
        margins = dpi(5),
        button
    }

	return templ
end

local function init (s)
	--i dont recall how but load order is fucked if these are somewhere else
	--[[local menu 	= require "ui.bar.popups.menu"
	local quicksettings = require "ui.bar.popups.quicksettings"
	local launcher = require "ui.bar.popups.launcher"]]

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

    local systray = s == screen.primary and popup_button(wibox.widget {
        widget = wibox.container.place,
        valign = 'center',
        {
            widget = wibox.widget.systray,
            base_size = dpi(20),
        }
    }, nil, s) or nil

	s.quicksettings_trigger = quicksettings_trigger

	local bar_widget
	bar_widget = wibox.widget {
        widget = wibox.container.background,
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
			popup_button({
					widget = wibox.widget.imagebox,
					image = os.getenv("HOME") .. "/.config/awesome/assets/Nix.svg"
				}, "launcher", s
			),
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
				popup_button(
				{
					layout = wibox.layout.fixed.horizontal,
					{
						widget = wibox.widget.textclock,
						format = "%H",
						font = beautiful.font_bold .. " 18"
					},
					{
						widget = wibox.container.background,
						fg = beautiful.gray,
						{
							widget = wibox.widget.textclock,
							format = "%M",
							font = beautiful.font_bold .. " 18"
						}
					},
					{
						widget = wibox.container.margin,
						margins = dpi(5),
						wibox.widget.base.make_widget()
					},
					{
						widget = wibox.widget.textclock,
						font = beautiful.font .. " 11",
						format = "%A"
					}
				},
				"menu",
				s),
				popup_button(
					quicksettings_trigger, "quicksettings", s
				)
			}
		},
        }
	}

	s.bar = wibox {
		ontop = true,
		visible = true,
		x = s.geometry.x,
		y = s.geometry.y, --+ s.geometry.height - beautiful.wibar_height,
		height = beautiful.wibar_height,
		width = s.geometry.width,
		screen = s,
		shape = gears.shape.rectangle,-- beautiful.theme_shape,
		widget = bar_widget,
		type = 'dock'
	}

	s.bar:struts ({
		top = beautiful.wibar_height
	})

	for _, p in ipairs(popups) do
		require("ui.bar.popups." .. p).init(s)
	end
end

local function hide(s)
	s.bar.visible = false
	hide_all_popups_on_screen(s, false)
end

local function show(s)
	s.bar.visible = true
	for _, p in ipairs(popups) do
		if s[p .. "_stat"] then
			require("ui.bar.popups." .. p).show(s)
			break
		end
	end
end

local function display_pending_notifs()
	if not quicksettings_trigger:index(notif_indicator) then
		quicksettings_trigger:insert(1, notif_indicator)
	end
end

local function no_pending_notifs()
	if quicksettings_trigger:index(notif_indicator) then
		quicksettings_trigger:remove_widgets(notif_indicator)
	end
end

local function pctl_song_active()
    quicksettings_trigger:insert(1, pctl_indicator)
end

local function pctl_song_inactive()
    quicksettings_trigger:remove_widgets(pctl_indicator)
end

return {
	init	= init,
	hide	= hide,
	show	= show,
    notifcenter_filled = display_pending_notifs,
    notifcenter_cleared = no_pending_notifs,
    pctl_active = pctl_song_active,
    pctl_inactive = pctl_song_inactive
}
