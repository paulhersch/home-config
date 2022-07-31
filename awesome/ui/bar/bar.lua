local wibox	= require "wibox"
local awful	= require "awful"
local gears	= require "gears"
local beautiful = require "beautiful"
local naughty	= require "naughty"
local dpi	= beautiful.xresources.apply_dpi

local helpers	= require "helpers"
--local menu	= require "bar.menu"
local battery   = require "ui.bar.widgets.battery"
local menu 	= require "ui.menu"
local notifcenter = require "ui.notifcenter"

local function init (s)
	menu.init(s)
    notifcenter.init(s)
--	local menu_box = s == screen.primary and menu.init() or nil
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
                top = dpi(5),
                bottom = dpi(5)
            },
			{
				widget = wibox.container.background,
				shape = function(cr,w,h)
					return gears.shape.rounded_rect(cr,w,h,dpi(5))
				end,
				{
					widget = wibox.container.background,
					id = 'background_role',
					{
							{
							widget = wibox.widget.textbox,
							font = beautiful.font_bold,
							id = 'text_role'
						},
						widget = wibox.container.place,
						halign = 'center',
						forced_width = beautiful.wibar_height - dpi(10),
					},
				}
			},
			create_callback = function(self, t, _, _)
				self:connect_signal("mouse::enter", function()
					self:get_children_by_id('background_role')[1].bg = beautiful.bg_focus
				end)
				self:connect_signal("mouse::leave", function()
					if not t.selected then
						self:get_children_by_id('background_role')[1].bg = beautiful.bg_normal
					end
				end)
				self:connect_signal("button::press", function(_, _, _, b)
					if b == 1 then t:view_only() end
				end)
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
				s.taglist,
			},
			{
                widget = wibox.container.place,
                halign = 'center',
                fill_horizontal = false,
                {
                    widget = wibox.widget.textclock,
                    font = beautiful.font_bold,
                    format = '%H:%M',
                    id = 'center_trigger',
                    --widget = wibox.widget.textbox,
                    --text = "menu"
                }
			},
			{
				widget = wibox.container.place,
				halign = 'right',
				fill_horizontal = false,
				{
					{
						{
							widget = wibox.container.rotate,
							direction = 'east',
							battery,
						},
						s.systray,
                        {
                            widget = wibox.widget.imagebox,
                            resize = true,
                            image = gears.color.recolor_image(gears.filesystem.get_configuration_dir() .. "/assets/materialicons/comment.svg", beautiful.fg_normal),
                            id = 'notifcenter_trigger'
                        },
						layout = wibox.layout.fixed.horizontal,
						spacing = dpi(5),
					},
					widget = wibox.container.margin,
					margins = dpi(5),
				}
			},
		}
	}
	s.bar:struts ({
		top = beautiful.wibar_height-- + 2*beautiful.useless_gap
	})

	s.center_open = true
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
	s.notifcenter_open = true
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

return {
	init	= init,
	hide	= hide,
	show	= show
}
