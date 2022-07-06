local wibox	= require "wibox"
local awful	= require "awful"
local aw	= awful.widget
local beautiful	= require "beautiful"
local gears	= require "gears"
local dpi	= beautiful.xresources.apply_dpi

local function init(s)
	local layoutlist = wibox {
		ontop	= true,
		visible = true,
		placement	= awful.placement.centered,
		width	= dpi(100),
		height	= dpi(100),
		shape	= gears.shape.rounded_rect,
		bg	= beautiful.bg_normal,
		widget	= aw.layoutlist {
			screen		= s,
			base_layout	= wibox.widget {
				spacing		= beautiful.menu_item_spacing,
				forced_num_cols	= 3,
				layout		= wibox.layout.grid.vertical,
				horizontal_expand= true,
				vertical_expand	= true,
			},
			widget_template	= wibox.widget {
				{
					{
						{
							id		= 'icon_role',
							resize		= true,
							widget		= wibox.widget.imagebox,
						},
						margins	= beautiful.menu_item_spacing/2,
						widget	= wibox.container.margin,
					},
					id		= 'background_role',
					shape		= gears.shape.rounded_rect,
					widget		= wibox.container.background,
				},
				widget	= wibox.container.background,
				bg	= beautiful.bg_normal,
			},
		}
	}
	return layoutlist
end

local function open(layoutlist,s)
	layoutlist.x		= s.geometry.x + s.geometry.width - beautiful.wibar_height - dpi(150) --more or less a proper square in the corner, no?
	layoutlist.y		= s.geometry.y + beautiful.menu_item_spacing/2 + dpi(100)
	layoutlist.width	= dpi(150)
	layoutlist.height	= dpi(100) --yeah i just assumed its a square, whatchu gon do about it huh
end

local function close(layoutlist,s)
	layoutlist.x		= s.geometry.x + s.geometry.width - beautiful.wibar_height --more or less a proper square in the corner, no?
	layoutlist.y		= s.geometry.y + beautiful.menu_item_spacing/2
	layoutlist.width	= beautiful.wibar_height - beautiful.menu_item_spacing
	layoutlist.height	= beautiful.wibar_height - beautiful.menu_item_spacing --yeah i just assumed its a square, whatchu gon do about it huh
end

return {
	init	= init,
	open	= open,
	close	= close,
}
