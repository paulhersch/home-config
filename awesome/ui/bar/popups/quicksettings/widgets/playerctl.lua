local wibox = require "wibox"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local gfs = require "gears.filesystem"
local gcl = require "gears.color"
local awful = require "awful"
local gears = require "gears"
local pctl = require("lgi").require("Playerctl")
local cairo = require("lgi").cairo
local Description = require("ui.components.container").description

local helpers = require "helpers"

local maticons = gfs.get_configuration_dir() .. "/assets/materialicons/"

--janky statekeeping, true if widget is currently shown, so that
--the progressbar does not have to update when it is not seen
local currently_updating = false

local widget = wibox.widget {
	id = "list",
	layout = wibox.layout.fixed.vertical,
	spacing = dpi(5)
}

local function show_icon()
    require "ui.bar.popups.quicksettings".show_note()
end
local function hide_icon()
    require "ui.bar.popups.quicksettings".hide_note()
end

local inactive_color, active_color = beautiful.bg_focus, beautiful.fg_normal
local template = {
    layout = wibox.layout.fixed.vertical,
    spacing = dpi(5),
    {
        id = "title",
        markup = "nothing playing",
        widget = wibox.widget.textbox,
        font = beautiful.font .. " 11",
        ellipsize = 'end',
    },
    {
        widget = wibox.container.constraint,
        bottom = dpi(5),
        {
            id = "artist",
            markup = "nothing playing",
            widget = wibox.widget.textbox,
            font = beautiful.font .. " 10",
            ellipsize = 'end',
        }
    },
    {
        widget = wibox.container.constraint,
        height = dpi(20),
        {
            layout = wibox.layout.align.horizontal,
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(10),
                {
                    id = "playpause",
                    image = gcl.recolor_image(maticons .. "play.svg", beautiful.bg_normal),
                    widget = wibox.widget.imagebox
                },
                {
                    id = "prev",
                    image = gcl.recolor_image(maticons .. "previous.svg", beautiful.fg_normal),
                    widget = wibox.widget.imagebox
                }
            },
            {
                widget = wibox.container.place,
                valign = "center",
                {
                    id = "progress",
                    widget = wibox.widget.progressbar,
                    forced_height = dpi(2),
                    max_value = 100,
                    border_width = 0,
                    color = beautiful.fg_normal,
                    background_color = inactive_color,
                }
            },
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(10),
                {
                    id = "next",
                    image = gcl.recolor_image(maticons .. "next.svg", beautiful.fg_normal),
                    widget = wibox.widget.imagebox
                },
                {
                    id = "shuffle",
                    image = gcl.recolor_image(maticons .. "shuffle.svg", inactive_color),
                    widget = wibox.widget.imagebox
                },
                {
                    id = "repeat",
                    image = gcl.recolor_image(maticons .. "repeat.svg", inactive_color),
                    widget = wibox.widget.imagebox
                }
            }
        }
    }
}

local function func_on_click(w, on_press)
    w:add_button(awful.button {
        modifiers = {},
        button = 1,
        on_press = on_press
    })
    helpers.pointer_on_focus(w)
end

local hex_to_char = function(x)
  return string.char(tonumber(x, 16))
end

local unescape = function(url)
  return url:gsub("%%(%x%x)", hex_to_char)
end

local function image_with_gradient(image)
    local surf = gears.surface.load_uncached(image)

    local cr = cairo.Context(surf)
    local w, h = gears.surface.get_size(surf)
    cr:rectangle(0, 0, w, h)

    local pat_h = cairo.Pattern.create_linear(0, 0, w, 0)
    pat_h:add_color_stop_rgba(0 ,gears.color.parse_color(beautiful.bg_focus_dark))
    pat_h:add_color_stop_rgba(0.2 ,gears.color.parse_color(beautiful.bg_focus_dark))
    pat_h:add_color_stop_rgba(0.6 ,gears.color.parse_color(beautiful.bg_focus_dark .. "BB"))
    pat_h:add_color_stop_rgba(0.8 ,gears.color.parse_color(beautiful.bg_focus_dark .. "99"))
    pat_h:add_color_stop_rgba(1 ,gears.color.parse_color(beautiful.bg_focus_dark .. "88"))
    cr:set_source(pat_h)
    cr:fill()

    return surf
end

local function set_bg_with_gradient(player_widget, path)
    player_widget.bgimage = image_with_gradient(path)
end

local function update_widget_meta(w, meta, player)
	local val = meta.value

    local title = val["xesam:title"]
    if title then
        title = gears.string.xml_escape(title)
    else
        title = "no title metadata"
    end

	local artists, artist_string = val["xesam:artist"], "no artist metadata"
    if artists then
        artist_string = artists[1]
	    for i = 2, #artists do
		    artist_string  = artist_string .. ", " .. artists[i]
	    end
        artist_string = gears.string.xml_escape(artist_string)
    end

    local length = val["mpris:length"]
    if length then
        w:get_children_by_id("progress")[1].max_value = math.floor(length / 1000000)
    end

	w:get_children_by_id("title")[1]:set_markup_silently(title)
	w:get_children_by_id("artist")[1]:set_markup_silently(artist_string)

    local art = val["mpris:artUrl"]
    if art then
        -- if player.player_name == "mopidy" then
        --     string.gsub(art, "/local", "file://" .. os.getenv("HOME") .. "/.local/share/mopidy/local/images")
        --     print(art)
        -- end
        if string.match(art, "file://") then
            -- hacks ahead: remove file://
            local path = string.sub(art, 7, string.len(art))
            path = unescape(path)
            if gears.filesystem.file_readable(path) then
                set_bg_with_gradient(w, path)
            end
        -- spotify spits out a random id that can be used on some cdn
        elseif player.player_name == "spotify" then
            -- strips last part of url
            local filename = art:match("([%d%a]+)/?$")
            -- check for cached image
            local path = gears.filesystem.get_cache_dir() .. filename
            if gears.filesystem.file_readable(path) then
                set_bg_with_gradient(w, path)
            else
                awful.spawn.easy_async("curl -L -s " .. art .. " -o " .. path,
                    function (_, _, _, code)
                        -- check if download was successful
                        if code == 0 then
                            set_bg_with_gradient(w, path)
                        end
                    end
                )
            end
        end
    end
end

local function timer_run(timer)
    if timer.started then
        timer:again()
    else
        timer:start()
    end
end

local function widget_from_player (player)
    local w = Description {
        widget = template,
        description = player.player_name:gsub("^%l", string.upper),
    }

    if not w then
        error("couldnt construct widget for " .. player.name)
        return nil
    end

    local function update_pos()
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
			gcl.recolor_image(maticons .. "play.svg", beautiful.fg_normal))
        progresstimer:stop()
	end

	player.on_play = function (_, _)
		w:get_children_by_id("playpause")[1]:set_image(
			gcl.recolor_image(maticons .. "pause.svg", beautiful.fg_normal))
        if currently_updating then
            timer_run(progresstimer)
        end
	end

	player.on_metadata = function (_, meta, _)
		update_widget_meta(w, meta, player)
	end

	player.on_shuffle = function (_, shuffle, _)
		w:get_children_by_id("shuffle")[1]:set_image(
			gcl.recolor_image(maticons .. "shuffle.svg", shuffle and active_color or inactive_color))
	end

	player.on_loop_status = function(_, status, _)
		w:get_children_by_id("repeat")[1]:set_image(
			gcl.recolor_image(maticons .. "repeat.svg", status == "NONE" and inactive_color or active_color))
	end

	func_on_click(w:get_children_by_id("prev")[1], function() player:previous() end)
	func_on_click(w:get_children_by_id("playpause")[1], function() player:play_pause() end)
	func_on_click(w:get_children_by_id("next")[1], function() player:next() end)
	func_on_click(w:get_children_by_id("shuffle")[1], function() player:set_shuffle(not player.shuffle) end)
	func_on_click(w:get_children_by_id("repeat")[1], function () player:set_loop_status(player.loop_status == "NONE" and "PLAYLIST" or "NONE") end)

    widget:connect_signal("start_updating", function ()
        if player.playback_status == "PLAYING" then
            update_pos()
            timer_run(progresstimer)
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
        collectgarbage("collect")
	end

	----
	-- initial updates
	----
	w:get_children_by_id("playpause")[1]:set_image(gcl.recolor_image(maticons ..
		(player.playback_status == "PLAYING" and "pause.svg" or "play.svg"), beautiful.fg_normal))
	w:get_children_by_id("repeat")[1]:set_image(
		gcl.recolor_image(maticons .. "repeat.svg", player.loop_status == "NONE" and inactive_color or active_color))
	w:get_children_by_id("shuffle")[1]:set_image(
		gcl.recolor_image(maticons .. "shuffle.svg", player.shuffle and active_color or inactive_color))

    if player.position then
        update_pos()
    end

    if currently_updating then
        timer_run()
    end

	return w
end

local manager = pctl.PlayerManager()

local function start_managing(name, just_added)
	local player = pctl.Player.new_from_name(name)
	--needs to be done for the controls to work
	manager:manage_player(player)
	local new_widget = widget_from_player(player)
	-- initial update of metadata (doing it in the "add" function somehow kills the construction process)
	if not just_added then update_widget_meta(new_widget, player.metadata, player) end
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
    currently_updating = false
    widget:emit_signal("stop_updating")
end

function widget:enable_updates()
    currently_updating = true
    widget:emit_signal("start_updating")
end

return widget
