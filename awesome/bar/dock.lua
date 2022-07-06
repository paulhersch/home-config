local wibox	= require "wibox"
local beautiful	= require "beautiful"
local awful	= require "awful"
local gears	= require "gears"

local chel	= require "helpers".color
local rubato	= require "plugins.rubato"

local dpi	= beautiful.xresources.apply_dpi

local function init(args)
--argparse (tables are difficult wow) {{{
	local s		= args.screen or screen.primary
	local h		= args.height or dpi(50)
	local o		= args.offset or 5
	local shapes	= args.shapes and {
			dock	= args.shapes.dock or gears.shape.rectangle,
			status	= args.shapes.status or gears.shape.rounded_rect,
			bg	= args.shapes.bg or gears.shape.rounded_rect,
		} or {
			dock	= gears.shape.rounded_rect,
			status	= gears.shape.rounded_rect,
			bg	= gears.shape.rounded_rect,
	}
	local pinneds	= args.pinned_apps or nil
	local colors	= args.colors and {
			bg = args.colors.bg and {
				normal	= args.colors.bg.normal or beautiful.bg_normal,
				focus	= args.colors.bg.focus or beautiful.bg_normal,
				hover	= args.colors.bg.hover or beautiful.bg_focus,
				minimized=args.colors.bg.minimized or beautiful.bg_normal,
			} or {
				normal	= beautiful.bg_normal,
				focus	= beautiful.bg_normal,
				hover	= beautiful.bg_focus,
				minimized=beautiful.bg_normal,
			},
			status = args.colors.status and {
				normal	= args.colors.status.normal or beautiful.bg_focus,
				focus	= args.colors.status.focus or beautiful.fg_normal,
				hover	= args.colors.status.hover or beautiful.bg_focus,
				minimized=args.colors.status.minimized or beautiful.bg_focus,
			} or {
				normal	= beautiful.bg_focus,
				focus	= beautiful.fg_normal,
				hover	= beautiful.bg_focus,
				minimized=beautiful.bg_focus,
			}
		} or {
		status = {
			normal	= beautiful.bg_focus,
			focus	= beautiful.fg_normal,
			hover	= beautiful.bg_focus,
			minimized=beautiful.bg_focus,
		},
		bg = {
			normal	= beautiful.bg_normal,
			focus	= beautiful.bg_normal,
			hover	= beautiful.bg_focus,
			minimized=beautiful.bg_normal,
		}
	}
	local sizings	= args.sizings and {
			margins	= args.sizings.margins and {
				outer	= args.sizings.margins.outer or h/10,
				status	= args.sizings.margins.status or 0,
				icon	= args.sizings.margins.icon or h/10
			} or {
				outer	= h/10,
				status	= 0,
				icon	= h/10
			},
			widths	= args.sizings.widths and {
				widget = args.sizings.widths.widget or h,
				status = args.sizings.widths.status and {
					focused = args.sizings.status_width.focused or h/2,
					normal	= args.sizings.status_width.normal or h/3,
					minimized=args.sizings.status_width.minimized or h/10
				} or {
					focused = h/2,
					normal	= h/3,
					minimized=h/10
				},
			},
			heights		= args.sizings.heights and {
				icon = args.sizings.heights.icon or nil,
				status = args.sizings.heights.status or h/10,
			} or {
				icon = nil,
				status = h/10
			},

		} or {
			margins		= {
				outer	= h/10,
				status	= 0,
				icon	= h/10
			},
			widths	= {
				widget = h,
				status = {
					focused = h/2,
					normal	= h/3,
					minimized=h/10
				},
			},
			heights		= {
				icon = nil,
				status = h/10,
			}
	}
	-- }}}
	local sh_r, sh_g, sh_b,_ = chel.col_diff(beautiful.bg_focus, beautiful.fg_normal)
	local n_sh_r, n_sh_g, n_sh_b = chel.col_diff(colors.bg.normal, colors.bg.hover)
	-- tasklist creation {{{
	local tasklist = awful.widget.tasklist {
		screen	= s,
		source	= function()
			local ret = {}
			for _,t in ipairs(s.tags) do
				gears.table.merge(ret, t:clients())
			end
			return ret
		end, --sorts clients in order of their tags
		filter	= function(c)
			for _,p in ipairs(pinneds) do
				if p.class == c.class then return false end
			end
			return c.screen == s
		end, --filter pinned apps
		forced_height	= h,
		layout	= {
			layout = wibox.layout.fixed.horizontal
		},
		widget_template =
		{
			{
				{
					nil,
					{
						{
							{
								widget	= awful.widget.clienticon
							},
							widget = wibox.container.margin,
							margins = sizings.margins.icon,
						},
						widget	= wibox.container.place,
						halign	= 'center',
						valign	= 'center',
					},
					{
						{
							wibox.widget.base.make_widget(),
							forced_height	= sizings.heights.status,
							forced_width	= sizings.widths.status.normal,
							id		= 'status',
							shape		= shapes.status,
							widget		= wibox.container.background,
						},
						widget	= wibox.container.place, --so the bg widget doesnt get stretched
						halign	= 'center',
					},
					layout = wibox.layout.align.vertical,
				},
				widget	= wibox.container.background,
				shape	= shapes.bg,
				id	= 'bg',
				bg	= colors.bg.normal
			},
			id = 'main',
			widget	= wibox.container.margin,
			margins	= h/10,
			forced_width = h,
			forced_height = h,
			create_callback = function(self, c, _, _)
				local on_hover = rubato.timed {
					intro		= 0.02,
					outro		= 0.02,
					duration	= 0.2,
					rate		= 30,
					pos		= 0,
					subscribed	= function(pos)
						self:get_children_by_id('bg')[1].bg = chel.col_shift(colors.bg.normal, pos*(255*n_sh_r), pos*(255*n_sh_g), pos*(255*n_sh_b))
					end
				}
				local status_w = rubato.timed {
					intro		= 0.02,
					outro		= 0.02,
					duration	= 0.1,
					rate		= 30,
					pos		= self:get_children_by_id('status')[1].forced_width,
					subscribed	= function(pos)
						self:get_children_by_id('status')[1].forced_width = pos
					end
				}
				local status_c = rubato.timed {
					intro		= 0.04,
					outro		= 0.04,
					duration	= 0.2,
					rate		= 30,
					pos		= 0,
					subscribed	= function(pos)
						self:get_children_by_id('status')[1].bg	= chel.col_shift(colors.status.normal, math.floor(pos*(255*sh_r)), math.floor((sh_g*255)*pos), math.floor((sh_b*255)*pos))
					end
				}
				self:connect_signal("mouse::enter", function()
					on_hover.target = 1
				end)
				self:connect_signal("mouse::leave", function()
					on_hover.target = 0
				end)
				c:connect_signal("focus", function()
					status_c.target = 1
					status_w.target = sizings.widths.status.focused
				end)
				c:connect_signal("unfocus", function()
					status_c.target = 0
					status_w.target = sizings.widths.status.normal
				end)

				c:connect_signal("property::minimized", function()
					status_c.target = c.minimized and 0
					status_w.target = c.minimized and sizings.widths.status.minimized --signal also gets emitted when minimized turns false
				end)
				self:add_button( awful.button {
					modifiers	= {},
					button		= 1,
					on_press	= function()
						if not c.active then
							c:activate {
								context		= "through_dock",
								switch_to_tag	= true,
							}
						else
							c.minimized = true
						end
					end
				})
				if c.active --initial update
					then
						status_w.target	= sizings.widths.status.focused
						status_c.target = 1
					elseif c.minimized
						then
							status_w.target = sizings.widths.status.minimized
							status_c.target = 0
						else
							status_w.target = sizings.widths.status.normal
							status_c.target = 0
				end
			end
		}
	}

	-- }}}
	-- the funny desktop starters {{{
	local pinned_apps = { layout = wibox.layout.fixed.horizontal }
	if pinneds then
		for i,p in ipairs(pinneds) do
			local self = wibox.widget {
				{
					{
						nil,
						{
							{
								widget	= wibox.widget.imagebox,
								image	= p.icon,
								resize	= true,
							},
							widget	= wibox.container.place,
							halign	= 'center',
							valign	= 'center',
						},
						{
							{
								wibox.widget.base.make_widget(),
								forced_height	= h/10,
								forced_width	= h/10,
								id		= 'status',
								shape		= shapes.status,
								widget		= wibox.container.background,
							},
							widget	= wibox.container.place, --so the bg widget doesnt get stretched
							halign	= 'center',
						},
						layout = wibox.layout.align.vertical,
					},
					widget	= wibox.container.background,
					shape	= shapes.bg,
					id	= 'bg',
				},
				id = 'main',
				widget	= wibox.container.margin,
				margins	= h/10,
				forced_width = h,
				forced_height = h,
			}
			local hover = rubato.timed {
				intro		= 0.02,
				outro		= 0.02,
				duration	= 0.2,
				rate		= 30,
				pos		= 0,
				subscribed	= function(pos)
						self:get_children_by_id('bg')[1].bg = chel.col_shift(colors.bg.normal, pos*(255*n_sh_r), pos*(255*n_sh_g), pos*(255*n_sh_b))
				end
			}
			self:connect_signal("mouse::enter", function()
				hover.target = 1
			end)
			self:connect_signal("mouse::leave", function()
				hover.target = 0
			end)
			self.client = nil
			self:add_button(awful.button {
				modifiers = {},
				button	= 1,
				on_press = function()
					if self.client then
						if not self.client.active then
							self.client:activate {
								context		= "through_dock",
								switch_to_tag	= true,
							}
						else
							self.client.minimized = true
						end
					else
						awful.spawn.easy_async(p.start_cmd,function() end)
					end

				end
			})
			pinned_apps[i+1] = self
		end
	end
	--this tries to find out if a client is to be represented by a pinned app
	client.connect_signal("request::manage", function(c)
		local pin_index
		for i,p in ipairs(pinneds) do
			if p.class == c.class then pin_index = i break end
		end
		if pin_index ~= nil then --pin_index+1 because pinned_apps[0] is the layout
			local self = pinned_apps[pin_index+1] --doing this so i can copy from widget template

			local status_w = rubato.timed {
				intro		= 0.02,
				outro		= 0.02,
				duration	= 0.1,
				rate		= 30,
				pos		= self:get_children_by_id('status')[1].forced_width,
				subscribed	= function(pos)
					self:get_children_by_id('status')[1].forced_width = pos
				end
			}
			local status_c = rubato.timed {
				intro		= 0.04,
				outro		= 0.04,
				duration	= 0.2,
				rate		= 30,
				pos		= 0,
				subscribed	= function(pos)
					self:get_children_by_id('status')[1].bg	= chel.col_shift(beautiful.bg_focus, math.floor(pos*(255*sh_r)), math.floor((sh_g*255)*pos), math.floor((sh_b*255)*pos))
				end
			}
			self.client = c
			status_w.target = h/3 --because its already there
			c:connect_signal("focus", function()
				status_c.target = 1
				status_w.target = h/2
			end)
			c:connect_signal("unfocus", function()
				status_c.target = 0
				status_w.target = h/3
			end)
			c:connect_signal("property::minimized", function()
				status_c.target = 0
				status_w.target = h/10
			end)
			c:connect_signal("request::unmanage", function()
				self.client = nil
				status_w.target = 0
				self:get_children_by_id('status')[1].bg = beautiful.bg_normal
			end)
		end
	end)
	-- }}}
	local dock_box	= awful.popup {
		ontop	= true,
		screen	= s,
		x	= s.geometry.x + s.geometry.width/2,
		y	= s.geometry.y + s.geometry.height - (h + o),
		shape	= shapes.dock,
		widget	= {
			{
				{
					{
						pinned_apps,
						tasklist,
						layout	= wibox.layout.fixed.horizontal,
					},
					widget	= wibox.container.margin,
					margin	= sizings.margins.outer,
				},
				widget	= wibox.container.background,
				bg	= colors.bg.normal,
				shape	= shapes.dock,
			},
			widget	= wibox.container.place,
			halign	= 'center',
		}
	}

	dock_box:connect_signal("property::width", function() --for centered placement, wanted to keep the offset
		dock_box.x	= s.geometry.x + s.geometry.width/2 - dock_box.width/2
	end)

	local autohideanim = rubato.timed {
		intro	= 0.3,
		outro	= 0.1,
		duration= 0.4,
		pos	= 0,
		rate	= 60,
		easing	= rubato.quadratic,
		subscribed = function(pos)
			dock_box.y = s.geometry.y + s.geometry.height - ((pos*h) + o)
			dock_box.opacity = pos
		end
	}
	local autohidetimer = gears.timer {
		timeout	= 1,
		single_shot = true,
		callback = function() autohideanim.target = 0 end
	}
	dock_box:connect_signal("mouse::leave", function()
		autohidetimer:again()
	end)
	dock_box:connect_signal("mouse::enter", function()
		autohideanim.target = 1
		autohidetimer:stop()
	end)
	--adding the updates that tasklist apps recieve to pinned apps
	return dock_box
end


return {
	init	= init
}
