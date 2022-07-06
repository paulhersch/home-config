local wibox	= require "wibox"
local rubato	= require "plugins.rubato"
local beautiful	= require "beautiful"
local naughty	= require "naughty"
local gears	= require "gears"
local awful	= require "awful"

local dpi	= require "beautiful.xresources".apply_dpi

local spotify	= require "bar.widgets.spotify"
local battery	= require "bar.widgets.battery".widget
local audio	= require "bar.widgets.audio".widget

local function init()
	local s = screen.primary
	--menu wibox {{{
	local openheight	= 3*beautiful.menu_widget_base_unit + beautiful.menu_item_spacing
	local layout	= wibox.widget {
		layout		= wibox.layout.grid,
		homogeneous	= true,
		spacing		= beautiful.menu_item_spacing,
		horizontal_expand=true,
		vertical_expand	= true,
		forced_width	= beautiful.bar_date_width,
		forced_height	= dpi(openheight) --openheight is also used by the animations
	}
	local function wrapWidget (InWidget)
		local wrappedWidget = wibox.widget {
			{
				{
					InWidget,
					widget	= wibox.container.place,
					halign	= 'center',
					valign	= 'center',
				},
				widget	= wibox.container.margin,
				margins = beautiful.menu_item_spacing/2,
			},
			widget	= wibox.container.background,
			bg	= beautiful.bg_focus,
			shape	= gears.shape.rounded_rect
		}
		return wrappedWidget
	end
	layout:add_widget_at(wrapWidget(
		wibox.widget {
			{
				widget	= wibox.widget.systray,
			},
			widget	= wibox.container.margin,
			margins	= beautiful.menu_item_spacing,
		}),1,1,1,3)
	layout:add_widget_at(wrapWidget(spotify),2,1,2,2)
	layout:add_widget_at(wrapWidget(battery),2,3,1,1)
	layout:add_widget_at(wrapWidget(audio),2,3,1,1)
	layout:add_widget_at(wrapWidget(audio),3,3,1,1)
	local menu = wibox {
		visible	= true,
		ontop	= true,
		type	= 'dock',
		x	= screen.primary.geometry.x + (screen.primary.geometry.width - beautiful.bar_date_width)/2,
		y	= s.geometry.y + beautiful.wibar_height - 25,
		width	= beautiful.bar_date_width,
		height	= dpi(openheight),
		shape	= function(cr,w,h)
			return gears.shape.partially_rounded_rect(cr,w,h,false,false,true,true)
		end,
		widget	= wibox.widget {
			{
				layout,
				widget	= wibox.container.margin,
				margins	= {
					left	= beautiful.menu_item_spacing,
					right	= beautiful.menu_item_spacing,
					bottom	= beautiful.menu_item_spacing,
					top	= beautiful.menu_item_spacing/2
				}
			},
			widget	= wibox.container.background,
			bg	= beautiful.bg_primary,
		}
	}
--}}}
-- opening animation {{{
	menu.openanim	= rubato.timed {
		intro		= 0.19,
		outro		= 0.1,
		duration	= 0.3,
		rate		= 60,
		pos		= 1,
		easing		= rubato.quadratic,
		subscribed	= function(pos)
			menu.y		= pos * (beautiful.wibar_height - beautiful.useless_gap) + beautiful.useless_gap + screen.primary.geometry.y
			menu.height	= dpi(pos * (openheight - (beautiful.wibar_height-beautiful.useless_gap) ) + (beautiful.wibar_height-beautiful.useless_gap))
		end
	}
--}}}
-- visibility controls {{{
	function menu:open()
		self.openanim.target = 1
	end
	function menu:close()
		self.openanim.target = 0
	end
	function menu:hide()
		self.visible = false
	end
	function menu:show()
		self.visible = true
	end
--}}}
	return menu
end

return {
	init	= init
}
