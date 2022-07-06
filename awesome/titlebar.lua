local awful	= require "awful"
local t		= awful.titlebar
local ab	= awful.button
local wibox	= require "wibox"
local wc	= wibox.container
local wl	= wibox.layout
local b		= require "beautiful"
local dpi	= b.xresources.apply_dpi
local g		= require "gears"

local rubato	= require "plugins.rubato"
local chel	= require "helpers".color

local titlebar_size	= b.wibar_height*(3/4)
local icon_path		= g.filesystem.get_configuration_dir() .. "assets/titlebarbuttons/"

client.connect_signal("request::titlebars",function(c)
	local title_widgets = wibox.widget {
		{
			{
				{
					id	= 'close_icon',
					widget	= wibox.widget.imagebox,
					image	= icon_path .. "close.svg",
					resize	= true,
					opacity	= 0,
				},
				widget	= wc.margin,
				margins	= b.menu_item_spacing/2
			},
			id		= 'close',
			widget		= wc.background,
			bg		= b.bg_focus,
			forced_height	= titlebar_size - 2*b.menu_item_spacing,
			forced_width	= titlebar_size - 2*b.menu_item_spacing,
			shape		= g.shape.circle,
			buttons		= ab {
				modifiers 	= {},
				button		= 1,
				on_release	= function()
					c:kill()
				end
			}
		},
		{
			{
				{
					id	= 'minimize_icon',
					widget	= wibox.widget.imagebox,
					image	= icon_path .. "minimize.svg",
					resize	= true,
					opacity	= 0,
				},
				widget	= wc.margin,
				margins	= b.menu_item_spacing/2
			},
			id		= 'minimize',
			wibox.widget.base.make_widget(),
			widget		= wc.background,
			bg		= b.bg_focus,
			forced_height	= titlebar_size - 2*b.menu_item_spacing,
			forced_width	= titlebar_size - 2*b.menu_item_spacing,
			shape		= g.shape.circle,
			buttons		= ab {
				modifiers 	= {},
				button		= 1,
				on_release	= function()
					c.minimized = true
				end
			}
		},
		{
			{
				{
					id	= 'ontop_icon',
					widget	= wibox.widget.imagebox,
					image	= icon_path .. "ontop.svg",
					resize	= true,
					opacity	= 0,
				},
				widget	= wc.margin,
				margins	= b.menu_item_spacing/2
			},
			id		= 'ontop',
			wibox.widget.base.make_widget(),
			widget		= wc.background,
			bg		= b.bg_focus,
			forced_height	= titlebar_size - 2*b.menu_item_spacing,
			forced_width	= titlebar_size - 2*b.menu_item_spacing,
			shape		= g.shape.circle,
			buttons		= ab {
				modifiers 	= {},
				button		= 1,
				on_release	= function()
					c.ontop = not c.ontop
				end
			}
		},
		widget	= wl.fixed.vertical,
		spacing	= b.menu_item_spacing,
	}
	t(c, {
		position	= "left",
		size		= titlebar_size,
		bg		= "#00000000" --the funny bad AA
	}) : setup {
	   {
		{
			{
				title_widgets,
				widget	= wc.margin,
				margins	= {
					top = b.menu_item_spacing,
					left = b.menu_item_spacing,
					right = b.menu_item_spacing,
					bottom = b.menu_item_spacing
				}
			},
			widget		= wc.place,
			valign		= 'top',
			halign		= 'center',
		},
		c.class ~= "kitty" and {
			{
				t.widget.titlewidget(c),
				widget		= wc.rotate,
				direction	=  'east',
			},
			widget	= wc.place,
			valign	= 'center',
			halign	= 'center'
		},
		nil,
		layout	= wl.align.vertical,
	   },
	   widget	= wc.background,
	   bg		= b.bg_normal,
	   shape	= function(cr,w,h) return g.shape.partially_rounded_rect(cr,w,h,true,false,false,true) end
	}
	local a_l = 0.2
	local diffs = {r = {}, g = {}, b = {}}
	diffs.r.r, diffs.r.g, diffs.r.b = chel.col_diff(b.bg_focus, b.red)
	diffs.g.r, diffs.g.g, diffs.g.b = chel.col_diff(b.bg_focus, b.green)
	diffs.b.r, diffs.b.g, diffs.b.b = chel.col_diff(b.bg_focus, b.blue)

	local g_to_col = rubato.timed {
		duration	= a_l,
		intro		= a_l/3,
		easing		= rubato.quadratic,
		subscribed	= function(pos)
			title_widgets:get_children_by_id('close')[1].bg =
				chel.col_shift(b.bg_focus, diffs.r.r*255*pos, diffs.r.g*255*pos, diffs.r.b*255*pos)
			title_widgets:get_children_by_id('minimize')[1].bg =
				chel.col_shift(b.bg_focus, diffs.g.r*255*pos, diffs.g.g*255*pos, diffs.g.b*255*pos)
			title_widgets:get_children_by_id('ontop')[1].bg = c.ontop and b.blue or --ontop should be marked in some way or form
				chel.col_shift(b.bg_focus, diffs.b.r*255*pos, diffs.b.g*255*pos, diffs.b.b*255*pos)
		end
	}
	c:connect_signal("focus", function()
		g_to_col.target = 1
	end)
	c:connect_signal("unfocus", function()
		g_to_col.target	= 0
	end)
	local mi_icon_fade = rubato.timed{
		duration	= a_l,
		intro		= a_l/3,
		easing		= rubato.quadratic,
		subscribed	= function(pos)
			title_widgets:get_children_by_id('minimize_icon')[1].opacity = pos
		end
	}
	local on_icon_fade = rubato.timed{
		duration	= a_l,
		intro		= a_l/3,
		easing		= rubato.quadratic,
		subscribed	= function(pos)
			title_widgets:get_children_by_id('ontop_icon')[1].opacity = pos
		end
	}
	local cl_icon_fade = rubato.timed{
		duration	= a_l,
		intro		= a_l/3,
		easing		= rubato.quadratic,
		subscribed	= function(pos)
			title_widgets:get_children_by_id('close_icon')[1].opacity = pos
		end
	}
	title_widgets:get_children_by_id('close')[1]:connect_signal("mouse::enter",function() cl_icon_fade.target = 1 c:activate() end)
	title_widgets:get_children_by_id('close')[1]:connect_signal("mouse::leave",function() cl_icon_fade.target = 0 end)
	title_widgets:get_children_by_id('minimize')[1]:connect_signal("mouse::enter",function() mi_icon_fade.target = 1 c:activate() end)
	title_widgets:get_children_by_id('minimize')[1]:connect_signal("mouse::leave",function() mi_icon_fade.target = 0 end)
	title_widgets:get_children_by_id('ontop')[1]:connect_signal("mouse::enter",function() on_icon_fade.target = 1 c:activate() end)
	title_widgets:get_children_by_id('ontop')[1]:connect_signal("mouse::leave",function() on_icon_fade.target = 0 end)
end)
