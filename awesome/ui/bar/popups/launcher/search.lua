local wibox = require "wibox"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local lgi = require "lgi"
local Gio = lgi.Gio
local Gtk = lgi.require("Gtk", "3.0")
local gears = require "gears"
local awful = require "awful"
local helpers = require "helpers"

local naughty = require "naughty"

local capi = {
	screen = screen
}

local app_info = Gio.AppInfo
local icon_theme = Gtk.IconTheme.get_default()

local entry_template = {
	id = "bg",
	widget = wibox.container.background,
	bg = beautiful.bg_focus_dark,
	shape = beautiful.theme_shape,
	{
		widget = wibox.container.margin,
		margins = dpi(5),
		{
			layout = wibox.layout.align.horizontal,
			{
				widget = wibox.container.margin,
				margins = dpi(5),
				{
					id = "icon",
					widget = wibox.widget.imagebox,
					shape = beautiful.theme_shape
				}
			},
			{
				widget = wibox.container.place,
				valign = 'center',
				halign = 'left',
				{
					id = "nameanddesc",
					layout = wibox.layout.fixed.vertical,
					spacing = dpi(3),
					{
						id = "appname",
						widget = wibox.widget.textbox,
						font = beautiful.font .. " 12",
						forced_height = beautiful.get_font_height(beautiful.font .. " 12")
					},
				}
			},
			wibox.widget.base.make_widget()
		}
	}
}

local function replace_with_escapes(text)
	if text then
		text = text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub("'", "&#39;")
	end
	return text
end

--global table that stores entries for applications
local LAUNCHER_CACHED_ENTRIES = {}
for _, app in ipairs(app_info.get_all()) do
	if app:should_show() then
		--widget instance
		local widget = wibox.widget(entry_template)
		local icon_widget = widget:get_children_by_id("icon")[1]

		-- fetch data
		local name = replace_with_escapes(app:get_name())
		local desc = app:get_description()

		-- set info
		widget:get_children_by_id("appname")[1]:set_markup_silently("<span>" .. name .. "</span>")
		local app_icon = app:get_icon()
		if app_icon then
			local pathorname = app_icon:to_string()
			if pathorname then
				if string.find(pathorname, "/") then --Icon names dont contain slashes
					icon_widget:set_image(pathorname)
				else
					local icon_info = icon_theme:lookup_icon(pathorname, dpi(48), 0)
					if icon_info then
						local path = icon_info:get_filename()
						if path then
							icon_widget:set_image(path)
						end
					end
				end
			end
		end

		if desc then
			local desc_wid = wibox.widget {
				id = "description",
				widget = wibox.widget.textbox,
				font = beautiful.font .. " 10",
				markup = "<span font_style='italic' foreground='" .. beautiful.gray .. "'>" .. replace_with_escapes(desc) .. "</span>"
			}
			widget:get_children_by_id("nameanddesc")[1]:add(desc_wid)
		end

		-- connect signals
		local bg = widget:get_children_by_id("bg")[1]
		widget:connect_signal("mouse::enter", function ()
			bg.bg = beautiful.bg_focus
			local s = awful.screen.focused()
			s.popup_launcher_widget:get_children_by_id("grid")[1]:get_widgets_at(s.popup_launcher_widget.selected_entry, 1, 1, 1)[1].bg = beautiful.bg_focus_dark
			s.popup_launcher_widget.selected_entry = s.popup_launcher_widget:get_children_by_id("grid")[1]
					:get_widget_position(widget).row
		end)
		widget:connect_signal("mouse::leave", function ()
		end)
		widget:add_button( awful.button {
			modifiers = {},
			button = 1,
			on_press = function ()
				awful.screen.focused().popup_launcher_widget:stop_search()
				app:launch()
			end
		})
		helpers.pointer_on_focus(widget)

		LAUNCHER_CACHED_ENTRIES[#LAUNCHER_CACHED_ENTRIES+1] = { widget = widget, appname = name, appinfo = app }
	end
end

table.sort(LAUNCHER_CACHED_ENTRIES, function (a,b)
	return a.appname < b.appname
end)

local widget_template = {
	layout = wibox.layout.align.vertical,
	expand = "inside",
	--just setting this to something high so that the prompt is not resized after no entry is found
	forced_width = dpi(1000),
	wibox.widget.base.make_widget(),
	{
		id = 'grid',
		layout = wibox.layout.grid,
		homogeneous = true,
		forced_num_cols = 1,
		forced_num_rows = 9,
		expand = true,
		vertical_spacing = dpi(3),
	},
	{
		widget = wibox.container.margin,
		margins = { top = dpi(5) },
		{
			widget = wibox.container.background,
			bg = beautiful.bg_focus,
			shape = beautiful.theme_shape,
			{
				widget = wibox.container.margin,
				margins = dpi(5),
				{
					layout = wibox.layout.align.horizontal,
					expand = "inside",
					forced_height = beautiful.get_font_height(beautiful.font .. " 12")*(5/3.0),
					{
						widget = wibox.widget.imagebox,
						image = gears.color.recolor_image(gears.filesystem.get_configuration_dir() .. "/assets/materialicons/search.svg", beautiful.fg_normal),
						forced_width = beautiful.get_font_height(beautiful.font .. " 12"),
						valign = 'center'
					},
					{
						widget = wibox.container.margin,
						left = dpi(10),
						right = dpi(5),
						{
							id = "promptbox",
							widget = wibox.container.place,
							valign = 'center',
							halign = 'left',
							fill_content_horizontal = true,
							{
								id = 'prompttext',
								font = beautiful.font .. " 12",
								halign = 'left',
								--hint text
								markup = "<span font_style='italic'>search apps</span>",
								widget = wibox.widget.textbox
							}
						}
					},
					wibox.widget.base.make_widget()
				}
			}
		}
	}
}

local function init(s)
	s.popup_launcher_widget = wibox.widget(widget_template)
	local prompttext = s.popup_launcher_widget:get_children_by_id("prompttext")[1]
	local entry_grid = s.popup_launcher_widget:get_children_by_id("grid")[1]

	s.popup_launcher_widget.selected_entry = 1

	function s.popup_launcher_widget:stop_search()
		awful.keyboard.emulate_key_combination({}, "Escape")
	end

	function s.popup_launcher_widget:select_up()
		if s.popup_launcher_widget.selected_entry then
			if s.popup_launcher_widget.selected_entry > 1 then
				local old_hl = entry_grid:get_widgets_at(self.selected_entry, 1, 1, 1)[1]
				self.selected_entry = self.selected_entry - 1
				local new_hl = entry_grid:get_widgets_at(self.selected_entry, 1, 1, 1)
				if new_hl then
					old_hl:get_children_by_id('bg')[1].bg = beautiful.bg_focus_dark
					new_hl[1]:get_children_by_id('bg')[1].bg = beautiful.bg_focus
				end
			end
		else
			s.popup_launcher_widget.selected_entry = 9
			local items = entry_grid:get_widgets_at(9, 1, 1, 1)
			if items then
				items[1]:get_children_by_id('bg')[1].bg = beautiful.bg_focus
			end
		end
	end

	function s.popup_launcher_widget:reset()
		prompttext:set_markup_silently("<span font_style='italic'>search apps</span>")
		entry_grid:reset()
		local i = 1
		while i < 10 do
			entry_grid:add_widget_at(LAUNCHER_CACHED_ENTRIES[i].widget, 10-i, 1, 1, 1)
			i = i + 1
		end
	end

	function s.popup_launcher_widget:filter_entries(filter)
		local filtered = {}
		for _, entry in ipairs(LAUNCHER_CACHED_ENTRIES) do
			if string.match(string.lower(entry.appname), string.lower(filter)) then
				table.insert(filtered, entry.widget)
			end
		end
		entry_grid:reset()
		for i, entry in ipairs(filtered) do
			if i == 10 then break end
			entry_grid:add_widget_at(entry, 10-i, 1, 1, 1)
		end
	end

	function s.popup_launcher_widget:start_search()
		awful.prompt.run {
			textbox = prompttext,
			fg_cursor = beautiful.fg_normal,
			font = beautiful.font,
			hooks = {
				{{}, "Up", function (cmd)
					--naughty.notification { text = "up" }
					self:select_up()
					return cmd, true
				end}
			},
			changed_callback = function (cmd)
				s.popup_launcher_widget:filter_entries(cmd)
				collectgarbage("collect")
			end,
			done_callback = function ()
				s.popup_launcher_widget:reset()
			end
		}
	end

	function s.popup_launcher_widget:is_active()
		return prompttext.text ~= "search apps"
	end

	s.popup_launcher_widget:get_children_by_id("promptbox")[1]:add_button(awful.button{
		modifiers = {},
		button = 1,
		on_press = function ()
			s.popup_launcher_widget:start_search()
		end
	})

	-- initial fill
	s.popup_launcher_widget:reset()
	return s.popup_launcher_widget
end

return {
	init = init
}
