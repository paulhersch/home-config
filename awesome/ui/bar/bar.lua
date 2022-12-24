local wibox	= require "wibox"
local awful	= require "awful"
local gears	= require "gears"
local beautiful = require "beautiful"
local dpi	= beautiful.xresources.apply_dpi
local helpers	= require "helpers"

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
	"quicksettings"
}

local function hide_all_popups_on_screen(screen, override_shown)
	for _, p in ipairs(popups) do
		require("ui.bar.popups." .. p).hide(screen)
		if (override_shown) then screen[p .. "_stat"] = false end
	end
end

-- shortcut to wrap menu and quicksettings triggers (and also the "normal" widgets without popups, if popup_name is nil the popup wont be shown)
local function wrap_in_bg_and_popup_button(widget, popup_name, screen)
	local templ = wibox.widget {
		widget = wibox.container.margin,
		margins = dpi(5),
		{
			id = popup_name ~= nil and popup_name .. "_bg" or nil,
			widget = wibox.container.background,
			bg = beautiful.bg_focus_dark,
			shape = beautiful.theme_shape,
			{
				widget = wibox.container.margin,
				margins = dpi(5),
				widget
			},
			buttons = popup_name ~= nil and {
				awful.button {
					modifiers = {},
					button = 1,
					on_press = function ()
						if screen[popup_name .. "_stat"] then
							require("ui.bar.popups." .. popup_name).hide(screen)
						else
							hide_all_popups_on_screen(screen, true)
							require("ui.bar.popups." .. popup_name).show(screen)
						end
						screen[popup_name .. "_stat"] = not screen[popup_name .. "_stat"]
					end
				}
			}
		}
	}
	if popup_name ~= nil then
		local trigger_bg = templ[popup_name .. "_bg"]
		helpers.pointer_on_focus(templ)
		trigger_bg:connect_signal("mouse::enter", function ()
			if not screen[popup_name].visible then trigger_bg.bg = beautiful.bg_focus end
		end)
		trigger_bg:connect_signal("mouse::leave", function ()
			if not screen[popup_name].visible then trigger_bg.bg = beautiful.bg_focus_dark end
		end)
	end
	return templ
end

local function init (s)
	local menu 	= require "ui.bar.popups.menu"
	local quicksettings = require "ui.bar.popups.quicksettings"

    local tagged_tag_col = helpers.color.col_mix(beautiful.bg_focus_dark, beautiful.gray)

    s.taglist = awful.widget.taglist {
        screen		= s,
		filter		= awful.widget.taglist.filter.all,
		layout 		= {
            layout = wibox.layout.flex.horizontal,
            spacing = dpi(5)
        },
		widget_template = {
			widget = wibox.container.margin,
            {
                widget = wibox.container.background,
                id = 'bg',
                shape = beautiful.theme_shape,
                fg = beautiful.fg_normal,
                bg = beautiful.bg_focus_dark,
                {
                    {
                        widget = wibox.widget.textbox,
                        font = beautiful.font_bold,
                        halign = 'center',
                        id = 'index',
                        text = ' ',
                    },
                    widget = wibox.container.place,
                    halign = 'center',
                    forced_width = dpi(15),
                    forced_height = dpi(15),
                },
            },
            create_callback = function(self, t, _, _)
                self:connect_signal("button::press", function(_, _, _, b)
					if b == 1 then t:view_only() end
				end)
                helpers.pointer_on_focus(self, s.bar)
                self:get_children_by_id('bg')[1].bg = t.selected and beautiful.blue or (#t:clients() > 0 and tagged_tag_col or beautiful.bg_focus)
			end,
            update_callback = function (self, t, _, _)
                self:get_children_by_id('bg')[1].bg = t.selected and beautiful.blue or (#t:clients() > 0 and tagged_tag_col or beautiful.bg_focus)
            end
		}
	}

    local systray = s == screen.primary and wibox.widget {
        widget = wibox.container.place,
        valign = 'center',
        {
            widget = wibox.widget.systray,
            base_size = dpi(20),
        }
    } or nil

	s.quicksettings_trigger = quicksettings_trigger

	local widget
	widget = wibox.widget {
		layout = wibox.layout.flex.horizontal,
		{
			layout = wibox.layout.fixed.horizontal,
			spacing = dpi(5),
			--[[wrap_in_bg_and_popup_button({

			}, "launcher", s),]]
			{
				widget = wibox.container.place,
				halign = 'left',
				valign = 'top',
				fill_horizontal = false,
				wrap_in_bg_and_popup_button({
					widget = wibox.container.place,
					valign = 'center',
					fill_vertical = true,
					s.taglist,
				})
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
				wrap_in_bg_and_popup_button(systray, nil, s),

				wrap_in_bg_and_popup_button(
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
						font = beautiful.font_thin .. " 9",
						format = "%A"
					}
				},
				"menu",
				s),
				wrap_in_bg_and_popup_button(
				quicksettings_trigger,
				"quicksettings",
				s),
			}
		},
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
        widget = widget
	}

	s.bar:struts ({
		top = beautiful.wibar_height
	})

	menu.init(s)
	quicksettings.init(s)
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
