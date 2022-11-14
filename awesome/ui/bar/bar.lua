local wibox	= require "wibox"
local awful	= require "awful"
local gears	= require "gears"
local beautiful = require "beautiful"
local dpi	= beautiful.xresources.apply_dpi

local helpers	= require "helpers"

local menu 	= require "ui.menu"
local quicksettings = require "ui.quicksettings"

local battery   = require "ui.bar.widgets.battery"

local notif_trigger = wibox.widget {
    widget = wibox.widget.imagebox,
    image = gears.color.recolor_image(gears.filesystem.get_configuration_dir() .. "assets/materialicons/notifications.svg", beautiful.fg_normal),
    buttons = {
        awful.button {
            modifiers = {},
            button = 1,
            on_press = function ()
                local s = awful.screen.focused()
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
                    forced_width = beautiful.wibar_height - dpi(16),
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

    s.systray = s == screen.primary and wibox.widget.systray() or nil

	s.bar = wibox {
		ontop = true,
		visible = true,
		x = s.geometry.x + 2*beautiful.useless_gap,
		y = s.geometry.y + 2*beautiful.useless_gap,
		height = beautiful.wibar_height,
		width = s.geometry.width - 4*beautiful.useless_gap,
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
                    margins = { left = dpi(8), top = dpi(8) },
                    {
                        widget = wibox.container.constraint,
                        forced_height = beautiful.wibar_height - dpi(16),
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
                    margins = { top = dpi(5), right = dpi(4) },
                    {
                        widget = wibox.container.constraint,
                        height = beautiful.wibar_height - dpi(10),
                        {
                            s.systray,
                            {
                                widget = wibox.container.place,
                                valign = 'center',
                                battery,
                            },
                            helpers.pointer_on_focus(notif_trigger),
                            layout = wibox.layout.fixed.horizontal,
                            spacing = dpi(5),
                        },
                    }
                }
            },
        }
    }
    s.bar:struts ({
        top = beautiful.wibar_height + 2*beautiful.useless_gap
    })

    menu.init(s)
    quicksettings.init(s)

end

local function hide(s)
	s.bar.visible = false
	menu.hide(s)
end
local function show(s)
	s.bar.visible = true
    if s.center_open then menu.show(s) end
end

local function display_pending_notifs()
    notif_trigger:set_image(gears.color.recolor_image(gears.filesystem.get_configuration_dir() .. "assets/materialicons/notifications.svg", beautiful.blue))
end

local function no_pending_notifs()
    notif_trigger:set_image(gears.color.recolor_image(gears.filesystem.get_configuration_dir() .. "assets/materialicons/notifications.svg", beautiful.fg_normal))
end

return {
	init	= init,
	hide	= hide,
	show	= show,
    notifcenter_filled = display_pending_notifs,
    notifcenter_cleared = no_pending_notifs
}
