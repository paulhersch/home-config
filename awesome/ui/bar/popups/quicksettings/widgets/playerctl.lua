local wibox = require "wibox"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local gfs = require "gears.filesystem"
local gcl = require "gears.color"
local awful = require "awful"
local gears = require "gears"
local naughty = require "naughty"
local pctl = require("lgi").require("Playerctl")
local helpers = require "helpers"

local maticons = gfs.get_configuration_dir() .. "/assets/materialicons/"
--slighty janky statekeeping if widget is currently shown, so that
--the progressbar does not have to update when it is not seen
local currently_updating = false

local widget = wibox.widget {
	id = "list",
	layout = wibox.layout.fixed.vertical,
	spacing = dpi(5)
}

--signals for said statekeeping
widget:connect_signal("start_updating", function ()
    currently_updating = true
end)

widget:connect_signal("stop_updating", function ()
    currently_updating = false
end)

local function show_icon()
    require "ui.bar.bar".pctl_active()
end
local function hide_icon()
    require "ui.bar.bar".pctl_inactive()
end

--basewidth 440 (qs 450 - 2\*5 margin)
local inactive_color = helpers.color.col_mix(beautiful.bg_focus, beautiful.fg_normal)
local titlefont, artistfont, margin, basewidth = beautiful.font_bold .. " 12", beautiful.font_thin .. " 11", dpi(5), dpi(440)
local height = beautiful.get_font_height(titlefont) + beautiful.get_font_height(artistfont) + 3*margin

local template = {
	widget = wibox.container.background,
	bg = beautiful.bg_focus,
	shape = beautiful.theme_shape,
	{
        widget = wibox.container.margin,
        bottom = dpi(5),
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
					text = "no playername set",
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
				forced_width = basewidth - height - margin,
				halign = "left",
				{
					widget = wibox.container.margin,
					margins = { left = margin, bottom = margin, right = margin},
					{
						layout = wibox.layout.fixed.vertical,
						spacing = margin,
						{
							id = "title",
							markup = "nothing playing",
							widget = wibox.widget.textbox,
							font = titlefont,
							ellipsize = 'end',
							forced_height = beautiful.get_font_height(titlefont),
						},
						{
							id = "artist",
							markup = "nothing playing",
							widget = wibox.widget.textbox,
							font = artistfont,
							ellipsize = 'end',
							forced_height = beautiful.get_font_height(artistfont),
						}
					}
				}
			},
            {
                widget = wibox.container.place,
                halign = 'right',
                valign = 'center',
                {
                    widget = wibox.container.margin,
                    margins = dpi(7),
                    {
                        id = "playpause_bg",
                        widget = wibox.container.background,
                        bg = beautiful.gray,
                        shape = beautiful.theme_shape,
                        {
                            widget = wibox.container.margin,
                            margins = dpi(5),
                            {
                                id = "playpause",
                                image = gcl.recolor_image(maticons .. "play.svg", beautiful.bg_normal),
                                widget = wibox.widget.imagebox
                            },
                        }
                    }
                }
            },
        },
        {
            widget = wibox.container.constraint,
            height = dpi(20),
            {
                widget = wibox.container.margin,
                margins = {left = 2*margin, right = 2*margin },
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = 4*margin,
                    {
                        id = "prev",
                        image = gcl.recolor_image(maticons .. "previous.svg", beautiful.fg_normal),
                        widget = wibox.widget.imagebox
                    },
                    {
                        widget = wibox.container.place,
                        valign = 'center',
                        {
                            id = "progress",
                            widget = wibox.widget.progressbar,
                            forced_height = dpi(5),
                            max_value = 100,
                            forced_width = basewidth - 21*margin - dpi(80),
                            border_width = 0,
                            color = beautiful.fg_normal,
                            background_color = inactive_color,
                            shape = gears.shape.rounded_bar
                        }
                    },
                    {
                        id = "next",
                        image = gcl.recolor_image(maticons .. "next.svg", beautiful.fg_normal),
                        widget = wibox.widget.imagebox
                    },
                    {
                        id = "shuffle",
                        image = gcl.recolor_image(maticons .. "shuffle.svg", beautiful.bg_focus_dark),
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

local hex_to_char = function(x)
  return string.char(tonumber(x, 16))
end

local unescape = function(url)
  return url:gsub("%%(%x%x)", hex_to_char)
end

local function update_widget_meta(w, meta)
	local val = meta.value

	w:get_children_by_id("title")[1]:set_markup_silently(val["xesam:title"])

	local artists = val["xesam:artist"][1]
	for i = 2, #val["xesam:artist"] do
		artists  = artists .. ", " .. val["xesam:artist"][i]
	end
	w:get_children_by_id("artist")[1]:set_markup_silently(artists)
    local length = val["mpris:length"]
    if length then
        w:get_children_by_id("progress")[1].max_value = math.floor(length / 1000000)
    end

    -- prototype setting album art as background
    --[[local art = val["mpris:artUrl"]
    -- if the image is available from local storage
    if art and string.match(art, "file://") then
        local path = string.sub(art, 7, string.len(art))
        path = unescape(path)
        naughty.notification{message = path}
        if gears.filesystem.file_readable(path) then
            w.bgimage = path
        end
    end]]
end


local function widget_from_player (player)
	local w = wibox.widget(template)
	if w == nil then
		error("couldnt construct widget for " .. player.name)
		return nil
	end

    local function update_pos()
        --naughty.notification({message = "updating..."})
        local pos = math.floor(player.position / 1000000)
        w:get_children_by_id("progress")[1].value = pos
    end

    local progresstimer = gears.timer {
        timeout = 1,
        callback = update_pos
    }
	----
	-- signal connect
	----
	player.on_pause = function (_, _)
		w:get_children_by_id("playpause")[1]:set_image(
			gcl.recolor_image(maticons .. "play.svg", beautiful.bg_normal))
        w:get_children_by_id("playpause_bg")[1].bg = beautiful.gray
        progresstimer:stop()
	end

	player.on_play = function (_, _)
		w:get_children_by_id("playpause")[1]:set_image(
			gcl.recolor_image(maticons .. "pause.svg", beautiful.bg_normal))
        w:get_children_by_id("playpause_bg")[1].bg = beautiful.blue
        progresstimer:start()
	end

	player.on_metadata = function (_, meta, _)
		update_widget_meta(w, meta)
	end

	player.on_shuffle = function (_, shuffle, _)
		w:get_children_by_id("shuffle")[1]:set_image(
			gcl.recolor_image(maticons .. "shuffle.svg", shuffle and beautiful.fg_normal or inactive_color))
	end

	player.on_loop_status = function(_, status, _)
		w:get_children_by_id("repeat")[1]:set_image(
			gcl.recolor_image(maticons .. "repeat.svg", status == "NONE" and inactive_color or beautiful.fg_normal))
	end

	func_on_click(w:get_children_by_id("prev")[1], function() player:previous() end)
	func_on_click(w:get_children_by_id("playpause")[1], function() player:play_pause() end)
	func_on_click(w:get_children_by_id("next")[1], function() player:next() end)
	func_on_click(w:get_children_by_id("shuffle")[1], function() player:set_shuffle(not player.shuffle) end)
	func_on_click(w:get_children_by_id("repeat")[1], function () player:set_loop_status(player.loop_status == "NONE" and "PLAYLIST" or "NONE") end)

    widget:connect_signal("start_updating", function ()
        if player.playback_status == "PLAYING" then
            progresstimer:start()
        end
    end)
    widget:connect_signal("stop_updating", function ()
        progresstimer:stop()
    end)
	----
    -- deconstruct
    ----
	player.on_exit = function (_, _)
		widget:remove_widgets(w)
		w = nil
        if #widget:get_children() == 0 then hide_icon() end
	end

	----
	-- initial updates
	----
	w:get_children_by_id("playpause")[1]:set_image(gcl.recolor_image(maticons ..
		(player.playback_status == "PLAYING" and "pause.svg" or "play.svg"), beautiful.bg_normal))
	w:get_children_by_id("repeat")[1]:set_image(
		gcl.recolor_image(maticons .. "repeat.svg", player.loop_status == "NONE" and inactive_color or beautiful.bg_normal))
	w:get_children_by_id("shuffle")[1]:set_image(
		gcl.recolor_image(maticons .. "shuffle.svg", player.shuffle and beautiful.bg_normal or inactive_color))
    if player.playback_status == "PLAYING" then
        w:get_children_by_id("playpause_bg")[1].bg = beautiful.blue
        if currently_updating then progresstimer:start() end
    else
        update_pos()
    end
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
    if #widget:get_children() == 0 then show_icon() end
	widget:insert(1, new_widget)
end

function manager:on_name_appeared (name, _)
	start_managing(name, true)
end

for _, name in ipairs(manager.player_names) do
	start_managing(name, false)
end

function widget:disable_updates()
    widget:emit_signal("stop_updating")
end

function widget:enable_updates()
    widget:emit_signal("start_updating")
end

return widget
