local wibox	= require "wibox"
local awful	= require "awful"
local gears	= require "gears"
local beautiful = require "beautiful"
local dpi	= beautiful.xresources.apply_dpi

local helpers	= require "helpers"
--local menu	= require "bar.menu"
local battery   = require "ui.bar.widgets.battery"
local menu 	= require "ui.menu"
local notifcenter = require "ui.notifcenter"
--local burger = require "plugins.awesome-widgets".hamburger({})

local function init (s)
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
			margins = {
                top = dpi(8),
                bottom = dpi(8)
            },
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
                --[[local def_bg = #t:clients() > 0 and tagged_tag_col or beautiful.bg_focus_dark
                function self:set_bg()
                    self:get_children_by_id('bg')[1].bg = t.selected and beautiful.blue or def_bg
                end
                t:connect_signal("tagged", function ()
                    def_bg = tagged_tag_col
                    self:set_bg()
                end)
                t:connect_signal("untagged", function ()
                    def_bg = #t:clients() > 0 and tagged_tag_col or beautiful.bg_focus_dark
                    self:set_bg()
                end)
                t:connect_signal("property::selected", function ()
                    self:set_bg()
                end)
				self:connect_signal("mouse::enter", function()
                    t.backup_bg = self:get_children_by_id('bg')[1].bg
					if not t.selected then
                        self:get_children_by_id('bg')[1].bg = helpers.color.col_mix(beautiful.blue, t.backup_bg)
                    end
				end)
				self:connect_signal("mouse::leave", function()
                    if self:get_children_by_id('bg')[1].bg ~= helpers.color.col_mix(beautiful.blue, t.backup_bg) then return end
					self:get_children_by_id('bg')[1].bg = t.backup_bg
				end)]]
				self:connect_signal("button::press", function(_, _, _, b)
					if b == 1 then t:view_only() end
				end)
                -- init
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
		x = s.geometry.x,-- + beautiful.useless_gap,
		y = s.geometry.y,-- + beautiful.useless_gap,
		height = beautiful.wibar_height,
		width = s.geometry.width,-- - 2*beautiful.useless_gap - 2*beautiful.border_width,
		screen = s,
		shape = gears.shape.rectangle,-- beautiful.theme_shape,
--		border_width = beautiful.border_width,
--		border_color = beautiful.bg_focus,
        widget = wibox.widget {
			layout = wibox.layout.flex.horizontal,
			{
				widget = wibox.container.place,
				halign = 'left',
				fill_horizontal = false,
                {
                    widget = wibox.container.margin,
                    margins = {
                        left = dpi(5)
                    },
                    s.taglist,
                }
			},
			{
                widget = wibox.container.place,
                halign = 'center',
                fill_horizontal = false,
                {
                    widget = wibox.widget.textclock,
                    font = beautiful.font_bold,
                    format = '%a, %d. %B um %H:%M',
                    id = 'center_trigger',
                    --widget = wibox.widget.textbox,
                    --text = "menu"
                }
			},
			{
				widget = wibox.container.place,
				halign = 'right',
				fill_horizontal = false,
                fill_vertical = true,
				{
					widget = wibox.container.margin,
					margins = dpi(5),
					{
						s.systray,
						{
							widget = wibox.container.place,
                            valign = 'center',
							battery,
						},
                        {
                            --[[widget = wibox.widget.imagebox,
                            resize = true,
                            image = gears.color.recolor_image(gears.filesystem.get_configuration_dir() .. "/assets/materialicons/comment.svg", beautiful.fg_normal),]]
                            id = 'notifcenter_trigger',
                            widget = wibox.widget.imagebox,
                            image = gears.color.recolor_image(gears.filesystem.get_configuration_dir() .. "assets/materialicons/notifications.svg", beautiful.fg_normal)
                        },
						layout = wibox.layout.fixed.horizontal,
						spacing = dpi(5),
					},
				}
			},
		}
	}
	s.bar:struts ({
		top = beautiful.wibar_height-- + 2*beautiful.useless_gap
	})

	menu.init(s)
    notifcenter.init(s)
	s.center_open = false
	s.bar:get_children_by_id('center_trigger')[1]:connect_signal("button::press", function(_, _, _, button)
		if button == 1 then
			if s.center_open then
				menu.hide(s)
			else
				menu.show(s)
			end
			s.center_open = not s.center_open
		end
	end)
	helpers.pointer_on_focus(s.bar:get_children_by_id('center_trigger')[1], s.bar)
	s.notifcenter_open = false
	s.bar:get_children_by_id('notifcenter_trigger')[1]:connect_signal("button::press", function(_, _, _, button)
		if button == 1 then
			if s.notifcenter_open then
				notifcenter.hide(s)
			else
				notifcenter.show(s)
			end
			s.notifcenter_open = not s.notifcenter_open
		end
	end)
	helpers.pointer_on_focus(s.bar:get_children_by_id('notifcenter_trigger')[1], s.bar)
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
    for s in screen do
        s.bar:get_children_by_id('notifcenter_trigger')[1]:set_image(gears.color.recolor_image(gears.filesystem.get_configuration_dir() .. "assets/materialicons/notifications.svg", beautiful.blue))
    end
end

local function no_pending_notifs()
    for s in screen do
        s.bar:get_children_by_id('notifcenter_trigger')[1]:set_image(gears.color.recolor_image(gears.filesystem.get_configuration_dir() .. "assets/materialicons/notifications.svg", beautiful.fg_normal))
    end
end

return {
	init	= init,
	hide	= hide,
	show	= show,
    notifcenter_filled = display_pending_notifs,
    notifcenter_cleared = no_pending_notifs
}
