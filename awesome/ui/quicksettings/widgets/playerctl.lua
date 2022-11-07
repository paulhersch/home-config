local wibox = require "wibox"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local gfs = require "gears.filesystem"
local gcl = require "gears.color"
local awful = require "awful"
local pctl = require("lgi").require("Playerctl")
local helpers = require "helpers"

local maticons = gfs.get_configuration_dir() .. "/assets/materialicons/"

local widget = wibox.widget {
	id = "list",
	layout = wibox.layout.fixed.vertical,
	spacing = dpi(5)
}

local titlefont, artistfont, margin = beautiful.font_bold .. " 11", beautiful.font_thin .. " 10", dpi(5)
local height = beautiful.get_font_height(titlefont) + beautiful.get_font_height(artistfont) + 3*margin

local template = {
	widget = wibox.container.background,
	bg = beautiful.bg_focus,
	shape = beautiful.theme_shape,
	{
		widget = wibox.layout.fixed.vertical,
		spacing = margin,
		{
			widget = wibox.container.background,
			bg = beautiful.bg_focus_dark,
			{
				widget = wibox.container.margin,
				margins = dpi(3),
				{
					id = "playername",
					text = "no player",
					widget = wibox.widget.textbox,
					font = titlefont
				}
			}
		},
		{
			layout = wibox.layout.fixed.horizontal,
			forced_height = height,
			{
				widget = wibox.container.place,
				content_fill_horizontal = true,
				--basewidth 440 (qs 450 - 2*5 margin)
				forced_width = dpi(440) - 2*height - margin,
				halign = "left",
				{
					widget = wibox.container.margin,
					margins = margin,
					{
						layout = wibox.layout.fixed.vertical,
						spacing = margin,
						{
							id = "title",
							text = "nothing playing",
							widget = wibox.widget.textbox,
							font = titlefont
						},
						{
							id = "artist",
							text = "nothing playing",
							widget = wibox.widget.textbox,
							font = artistfont
						}
					}
				}
			},
			{
				widget = wibox.container.place,
				halign = 'center',
				valign = 'left',
				{
					layout = wibox.layout.flex.horizontal,
					forced_width = 2*height,
					{
						id = "shuffle",
						image = gcl.recolor_image(maticons .. "shuffle.svg", beautiful.bg_focus_dark),
						widget = wibox.widget.imagebox
					},
					{
						id = "prev",
						image = gcl.recolor_image(maticons .. "previous.svg", beautiful.fg_normal),
						widget = wibox.widget.imagebox
					},
					{
						id = "playpause",
						image = gcl.recolor_image(maticons .. "play.svg", beautiful.fg_normal),
						widget = wibox.widget.imagebox
					},
					{
						id = "next",
						image = gcl.recolor_image(maticons .. "next.svg", beautiful.fg_normal),
						widget = wibox.widget.imagebox
					},
					{
						id = "repeat",
						image = gcl.recolor_image(maticons .. "repeat.svg", beautiful.bg_focus_dark),
						widget = wibox.widget.imagebox
					}
				}
			}
		}
	}
}

local function func_on_click(w, on_press)
	w:add_button(
		awful.button {
			modifiers = {},
			button = 1,
			on_press = on_press
		}
	)
	helpers.pointer_on_focus(w)
end

local function update_widget_meta(w, meta)
	local val = meta.value

	w:get_children_by_id("title")[1].text = val["xesam:title"]

	local artists = val["xesam:artist"][1]
	for i = 2, #val["xesam:artist"] do
		artists  = artists .. ", " .. val["xesam:artist"][i]
	end
	w:get_children_by_id("artist")[1].text = artists
end

local function widget_from_player (player)
	local w = wibox.widget(template)
	if w == nil then
		error("couldnt construct widget for " .. player.name)
		return nil
	end
	----
	-- signal connect
	----
	player.on_pause = function (_, _)
		w:get_children_by_id("playpause")[1]:set_image(
			gcl.recolor_image(maticons .. "play.svg", beautiful.fg_normal))
	end

	player.on_play = function (_, _)
		w:get_children_by_id("playpause")[1]:set_image(
			gcl.recolor_image(maticons .. "pause.svg", beautiful.fg_normal))
	end

	player.on_metadata = function (_, meta, _)
		update_widget_meta(w, meta)
	end

	player.on_shuffle = function (_, shuffle, _)
		w:get_children_by_id("shuffle")[1]:set_image(
			gcl.recolor_image(maticons .. "shuffle.svg", shuffle and beautiful.fg_normal or beautiful.bg_focus_dark))
	end

	player.on_loop_status = function(_, status, _)
		w:get_children_by_id("repeat")[1]:set_image(
			gcl.recolor_image(maticons .. "repeat.svg", status == "NONE" and beautiful.bg_focus_dark or beautiful.fg_normal))
	end

	func_on_click(w:get_children_by_id("prev")[1], function() player:previous() end)
	func_on_click(w:get_children_by_id("playpause")[1], function() player:play_pause() end)
	func_on_click(w:get_children_by_id("next")[1], function() player:next() end)
	func_on_click(w:get_children_by_id("shuffle")[1], function() player:set_shuffle(not player.shuffle) end)
	func_on_click(w:get_children_by_id("repeat")[1], function () player:set_loop_status(player.loop_status == "NONE" and "PLAYLIST" or "NONE") end)

	-- deconstruct
	player.on_exit = function (_, _)
		widget:remove_widgets(w)
		w = nil
	end
	----
	-- initial updates
	----
	w:get_children_by_id("playpause")[1]:set_image(gcl.recolor_image(maticons ..
		(player.playback_status == "PLAYING" and "pause.svg" or "play.svg"), beautiful.fg_normal))
	w:get_children_by_id("repeat")[1]:set_image(
		gcl.recolor_image(maticons .. "repeat.svg", player.loop_status == "NONE" and beautiful.bg_focus_dark or beautiful.fg_normal))
	w:get_children_by_id("shuffle")[1]:set_image(
		gcl.recolor_image(maticons .. "shuffle.svg", player.shuffle and beautiful.fg_normal or beautiful.bg_focus_dark))

	--gsub makes first letter uppercase, looks better Imo
	w:get_children_by_id("playername")[1].text = player.player_name:gsub("^%l", string.upper)

	return w
end

local manager = pctl.PlayerManager()

local function start_managing(name, just_added)
	local player = pctl.Player.new_from_name(name)
	--needs to be done for the controls to work
	manager:manage_player(player)
	local new_widget = widget_from_player(player)
	-- initial update of metadata (doing it in the "add" function somehow kills the construction process)
	if not just_added then update_widget_meta(new_widget, player.metadata) end
	widget:insert(1, new_widget)
end

function manager:on_name_appeared (name, _)
	start_managing(name, true)
end

for _, name in ipairs(manager.player_names) do
	start_managing(name, false)
end

return widget
