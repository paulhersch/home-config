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

local menu_trigger = wibox.widget {
    widget = wibox.widget.textclock,
    font = beautiful.font_bold,
    format = '%H:%M',
    id = 'menu_trigger',
    buttons = {
        awful.button {
            modifiers = {},
            button = 1,
            on_press = function ()
                local s = awful.screen.focused()
				local menu 	= require "ui.menu"
                if s.menu_open then
                    menu.hide(s)
                else
                    menu.show(s)
                end
                s.menu_open = not s.menu_open
            end
        }
    }
}

local function init (s)
	local menu 	= require "ui.menu"
	local quicksettings = require "ui.quicksettings"

    s.menu_open = false
    s.notifcenter_open = false

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
                    --wibox.widget.base.make_widget(),
                    widget = wibox.container.place,
                    halign = 'center',
                    forced_width = beautiful.wibar_height - dpi(26),
                },
            },
            create_callback = function(self, t, _, _)
                self:connect_signal("button::press", function(_, _, _, b)
					if b == 1 then t:view_only() end
				end)
                helpers.pointer_on_focus(self, s.bar)
			end,
            update_callback = function (self, t, _, _)
                self:get_children_by_id('bg')[1].bg = t.selected and beautiful.blue or (#t:clients() > 0 and tagged_tag_col or beautiful.bg_focus_dark)
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

	s.bar = wibox {
		ontop = true,
		visible = true,
		x = s.geometry.x,
		y = s.geometry.y,
		height = beautiful.wibar_height,
		width = s.geometry.width,
		screen = s,
		shape = gears.shape.rectangle,-- beautiful.theme_shape,
        widget = wibox.widget {
			layout = wibox.layout.flex.horizontal,
			{
				widget = wibox.container.place,
				halign = 'left',
                valign = 'top',
				fill_horizontal = false,
                {
                    widget = wibox.container.margin,
                    margins = dpi(13),
                    {
                        widget = wibox.container.constraint,
                        s.taglist
                    }
                }
			},
            {
                widget = wibox.container.place,
                halign = 'center',
                helpers.pointer_on_focus(menu_trigger),
            },
			{
				widget = wibox.container.place,
				halign = 'right',
                valign = 'top',
				fill_horizontal = false,
                fill_vertical = true,
				{
                    widget = wibox.container.margin,
                    margins = dpi(5),
                    {
                        layout = wibox.layout.fixed.horizontal,
                        spacing = dpi(5),
                        systray,
                        {
                            id = 'qs_trigger_bg',
                            widget = wibox.container.background,
                            shape = beautiful.theme_shape,
                            {
                                widget = wibox.container.margin,
                                margins = dpi(5),
                                helpers.pointer_on_focus(quicksettings_trigger)
                            },
                            buttons = {
                                awful.button {
                                    modifiers = {},
                                    button = 1,
                                    on_press = function ()
                                        if s.notifcenter_open then
                                            quicksettings.hide(s)
                                        else
                                            quicksettings.show(s)
                                        end
                                        s.notifcenter_open = not s.notifcenter_open
                                    end
                                }
                            }
                        }
                    }
                }
            },
        }
    }
    s.bar:struts ({
        top = beautiful.wibar_height
    })

    menu.init(s)
    quicksettings.init(s)

    local qs_trigger_bg = s.bar:get_children_by_id('qs_trigger_bg')[1]
    qs_trigger_bg:connect_signal("mouse::enter", function ()
        if not s.notifcenter_open then qs_trigger_bg.bg = beautiful.bg_focus end
    end)
    qs_trigger_bg:connect_signal("mouse::leave", function ()
        if not s.notifcenter_open then qs_trigger_bg.bg = beautiful.bg_normal end
    end)

end

local function hide(s)
	s.bar.visible = false
	s.menu:hide()
	s.notifcenter:hide()
end
local function show(s)
	s.bar.visible = true
    if s.center_open then s.menu:show() end
	if s.notifcenter_open then s.quicksettings:show() end
end

local function display_pending_notifs()
--    quicksettings_trigger:get_children_by_id('notif_icon')[1]
--                        :set_image(gears.color.recolor_image(gears.filesystem.get_configuration_dir() .. "assets/materialicons/mail_unread.svg", beautiful.fg_normal))
	if not quicksettings_trigger:index(notif_indicator) then
		quicksettings_trigger:insert(1, notif_indicator)
	end
end

local function no_pending_notifs()
--    quicksettings_trigger:get_children_by_id('notif_icon')[1]
--                        :set_image(gears.color.recolor_image(gears.filesystem.get_configuration_dir() .. "assets/materialicons/mail.svg", beautiful.fg_normal))
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
