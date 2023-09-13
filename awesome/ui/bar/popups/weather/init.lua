local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local cairo = require("lgi").cairo
local math = math
local settings = require("settings")
local json = require("rapidjson")
local pprint = require("plugins.pprint.pprint").pprint

local PopupBase = require("ui.bar.popups.base").new

local icon_path = gears.filesystem.get_configuration_dir() .. "assets/weathericons/"

local m = {}
local p = {
    ---@type WeatherWidget[]
    instances = {},
    current_data = {},
    trigger = wibox.widget {
        widget = wibox.container.background,
        {
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(10),
            {
                id = "icon",
                widget = wibox.widget.imagebox,
                image = gears.color.recolor_image(icon_path .. "01d.svg", beautiful.fg_normal),
                forced_height = dpi(20),
                forced_width = dpi(20),
            },
        }
    },
    first_render_complete = false,
    width = dpi(400),
    current_weather = {
        height = dpi(75),
    },
    forecast = {
        height = dpi(225),
    }
}

---@param rotation integer Rotation in degrees
---@param cr any Cairo context
---@param w integer width
---@param h integer height
---@return any drawing of an arrow rotated to the direction given in degrees
p.draw_wind_arrow = function(cr, w, h, rotation)
    local dist_wings = math.floor(w/5)
    local w2, h2 = math.floor(w/2), math.floor(h/2)
    cr:translate(w2, h2)
    cr:rotate(math.rad(rotation))
    cr:set_source_rgba(gears.color.parse_color(beautiful.fg_normal))
    cr:move_to(1, -h2+1)
    cr:line_to(dist_wings, h2-1)
    cr:line_to(1, h2-dist_wings)
    cr:line_to(-dist_wings, h2-1)
    cr:line_to(1, -h2+1)
    cr:stroke()
end

p.gradient = function (x1, x2, y1, y2)
    return (y2-y1)/(x2-x1)
end

---@return any widget displaying the current weather
p.render_current_weather = function ()
    local current_weather = p.current_data.current
    local layout = wibox.widget {
        layout = wibox.layout.grid,
        homogeneous = true,
        expand = true,
        spacing = dpi(5),
        forced_num_cols = 4,
        forced_num_rows = 2,
        forced_height = p.current_weather.height,
        forced_width = p.width
    }
    layout:add_widget_at(wibox.widget {
        widget = wibox.container.place,
        valign = "center",
        halign = "center",
        {
            widget = wibox.widget.imagebox,
            image = gears.color.recolor_image(
                icon_path .. current_weather.weather[1].icon .. ".svg",
                beautiful.fg_normal
            ),
            forced_height = p.current_weather.height*4/5,
            forced_width = p.current_weather.height*4/5
        }
    }, 1, 1, 2, 1)
    layout:add_widget_at(wibox.widget {
        widget = wibox.widget.textbox,
        valign = "bottom",
        halign = "left",
        text = string.format("%.1f°C", current_weather.temp),
        font = beautiful.font .. " 11"
    }, 1, 2, 1, 1)
    layout:add_widget_at(wibox.widget {
        widget = wibox.widget.textbox,
        valign = "top",
        halign = "left",
        text = string.format("Humid: %d %%", current_weather.humidity),
        font = beautiful.font .. " 11"
    }, 2, 2, 1, 1)
    layout:add_widget_at(wibox.widget {
        widget = wibox.container.place,
        valign = "bottom",
        halign = "left",
        {
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(5),
            {
                widget = wibox.container.place,
                valign = "top",
                halign = "center",
                {
                    widget = wibox.container.background,
                    forced_width = dpi(20),
                    forced_height = dpi(20),
                    bgimage = function(_, cr, w, h)
                        p.draw_wind_arrow(cr, w, h, current_weather.wind_deg)
                    end,
                    wibox.widget.base.make_widget()
                }
            },
            {
                    widget = wibox.widget.textbox,
                    text = string.format("%.1f m/s", current_weather.wind_speed),
                    font = beautiful.font .. " 11",
                valign = "top",
                halign = "left",
            }
        }
    }, 1, 3, 1, 1)
    layout:add_widget_at(wibox.widget {
        valign = "top",
        halign = "left",
        widget = wibox.widget.textbox,
        text = string.format("UV: %.2f", current_weather.uvi),
        font = beautiful.font .. " 11"
    }, 2, 3, 1, 1)
    layout:add_widget_at(wibox.widget {
        widget = wibox.widget.textbox,
        valign = "bottom",
        halign = "left",
        text = string.format("%.2f mm", current_weather.rain and current_weather.rain["1h"] or "0"),
        font = beautiful.font .. " 11"
    }, 1, 4, 1, 1)
    layout:add_widget_at(wibox.widget {
        widget = wibox.widget.textbox,
        text = string.format("%d hPa", current_weather.pressure),
        font = beautiful.font .. " 11",
        valign = "top",
        halign = "left",
    }, 2, 4, 1, 1)

    return layout
end

p.render_temp_graph = function (cr, w, h)
    local datapoints = {}
    for _, hour in ipairs(p.current_data.hourly) do
        table.insert(datapoints, {
            temp = hour.temp,
            time = hour.dt
        })
    end

    -- get max and min of datapoints to normalize graph for height
    -- as you still want to be able to decipher stuff the min or max
    -- (depending on how warm/cold it gets) has to be 0
    local max, min = 0, 0
    for _, dp in ipairs(datapoints) do
        max = max < dp.temp and dp.temp or max
        min = min > dp.temp and dp.temp or min
    end

    -- h_max = height - space for text
    -- we want to target 5/6 of the height (-x label height) -> h_target for later use
    -- factor to use for normalization + offset
    local h_max,font_height = h-dpi(20), dpi(13)
    local h_target, mintemp_abs = h_max*(5/6), math.abs(min)
    -- factor maps which temp needs to have which height
    -- h_offset is just half the diff between h_max and h_target to pad values
    local h_factor, h_offset = h_target/(mintemp_abs+max), (h_max - h_target)/2
    -- needed later to determine size of text stuffs
    cr:select_font_face(beautiful.font, cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL)
    cr:set_font_size(font_height)
    local dash_pattern = {dpi(6), dpi(4)}

    local function calc_y(temp)
        -- top left coord-system -> target - temp
        -- + min_abs to shift values upwards (cant have negative pixel vals)
        -- + h_offset to put values in middle of target area (otherwise one line would
        -- touch the border)
        return h_target - ((temp+mintemp_abs)*h_factor) + h_offset
    end

    -- remove unnessecary points and normalize temps to fit graph well
    local graph_datapoints = {}
    for i = 1, #datapoints, math.ceil(#datapoints/w) do
        table.insert(graph_datapoints, {
            temp = calc_y(datapoints[i].temp),
            time = os.date("%H:%M", datapoints[i].time)
        })
    end

    -- estimated cutoff needed when showing temps on left side of graph (4 glyphs + . and °)
    local w_start = dpi(45)
    local w_range = w-w_start-(
        cr:text_extents(graph_datapoints[#graph_datapoints].time).width/2
    )
    local w_factor = w_range/#graph_datapoints

    -- text
    for i = 0, 4, 1 do
        -- shift up because no <0, shift back down
        local temp = ((mintemp_abs+max)*(i/4))-mintemp_abs
        local y = calc_y(temp)
        cr:set_source_rgba(gears.color.parse_color(beautiful.fg_normal))
        cr:move_to(0, y+font_height/2) -- push down so mid is on line
        cr:show_text(string.format("%.1f°C", temp))
        cr:set_source_rgba(gears.color.parse_color(beautiful.bg_focus))
        cr:set_dash(dash_pattern, 1, 0)
        cr:move_to(w_start, y)
        cr:line_to(w_start+w_range, y)
        cr:stroke()
        cr:set_dash({}, 0, 0)
    end

    -- 0 line
    cr:set_source_rgba(gears.color.parse_color(beautiful.bg_focus))
    local h_0 = calc_y(0)
    cr:move_to(w_start+1, h_0)
    cr:line_to(w_start + w_range, h_0)
    cr:stroke()

    for i = 0, 4, 1 do
        -- similar to how index above is calculated
        -- max 4/5 so text does not get cut off
        -- also 1 base index things
        local dp_index = math.floor(#graph_datapoints*(i/4))
        local text = graph_datapoints[dp_index == 0 and 1 or dp_index].time
        local extents = cr:text_extents(text) --cairo.TextExtents(text)
        local x_pos = w_start+w_factor*dp_index
        cr:set_source_rgba(gears.color.parse_color(beautiful.fg_normal))
        cr:move_to(x_pos, h_max)
        cr:line_to(x_pos, h_max+dpi(4))
        cr:stroke()
        cr:move_to(x_pos-extents.width/2, h)
        cr:show_text(text)
        -- draw funny dashed lines
        if i > 0 and i < 4 then
            cr:set_source_rgba(gears.color.parse_color(beautiful.bg_focus))
            cr:set_dash(dash_pattern, 1, 0)
            cr:move_to(x_pos, h_max)
            cr:line_to(x_pos, 0)
            cr:stroke()
            cr:set_dash({}, 0, 0)
        end
    end

    -- draw coord-system lines
    cr:set_source_rgba(gears.color.parse_color(beautiful.fg_normal))
    cr:move_to(w_start, 0)
    cr:line_to(w_start, h_max)
    cr:line_to(w_start+w_range+1, h_max)
    cr:stroke()

    -- draw graph line
    cr:set_source_rgba(gears.color.parse_color(beautiful.fg_normal))
    cr:move_to(w_start,graph_datapoints[1].temp)
    for i = 2, #graph_datapoints do
        cr:line_to(w_start+w_factor*i, graph_datapoints[i].temp)
    end
    cr:stroke()
end

p.render_forecast = function ()
    local w = wibox.widget {
        widget = wibox.container.background,
        forced_height = p.forecast.height,
        bgimage = function (_, cr, w, h)
            p.render_temp_graph(cr, w, h)
        end
    }

    return w
end

p.widget = wibox.widget {
    layout = wibox.layout.fixed.vertical,
    spacing = dpi(5),
    {
        widget = wibox.container.background,
        forced_width = p.width,
        forced_height = p.current_weather.height,
        bg = beautiful.bg_focus,
        {
            widget = wibox.container.place,
            fill_vertical = true,
            fill_horizontal = true,
            {
                widget = wibox.widget.textbox,
                text = "no data"
            }
        }
    },
    {
        widget = wibox.container.background,
        bg = beautiful.bg_focus,
        forced_width = p.width,
        forced_height = p.forecast.height,
        {
            widget = wibox.container.place,
            fill_vertical = true,
            fill_horizontal = true,
            {
                widget = wibox.widget.textbox,
                text = "no data"
            }
        }
    }
}

p.render_widget = function ()
    p.widget:set(1, p.render_current_weather())
    p.widget:set(2, p.render_forecast())
end

p.update_trigger = function ()
    local current_weather = p.current_data.current.weather[1]
    p.trigger:get_children_by_id("icon")[1].image = gears.color.recolor_image(
        icon_path .. current_weather.icon .. ".svg",
        beautiful.fg_normal
    )
end

p.send_alerts = function ()
    if not p.current_data.alerts then
        return
    end
    for _, alert in ipairs(p.current_data.alerts) do
        naughty.notification {
            title = string.format(
                "%s von %s bis %s",
                alert.event,
                os.date("%d.%m %H:%M", alert.start),
                -- end will even be recognized as control string when its part of the table
                os.date("%d.%m %H:%M", alert["end"])
            ),
            message = alert.description,
            urgency = "critical",
            app_name = "Awesome WeatherWidget",
            icon = gears.color.recolor_image(icon_path .. "alert.svg", beautiful.fg_normal)
        }
    end
end

p.start_render = function ()
    local cmd = "curl 'https://api.openweathermap.org/data/2.5/onecall?lat=".. settings.get("weather.lat")
        .. "&lon=" .. settings.get("weather.lon")
        .. "&appid=" .. settings.get("weather.apikey")
        .. "&units=" .. settings.get("weather.units")
        .. "&exclude=minutely,daily&lang=de" .. "'"
    awful.spawn.easy_async(cmd, function (out, err, _, exitcode)
        if exitcode == 0 then
            local success, data = pcall(json.decode, out)
            if success then
                p.current_data = data
                p.update_trigger()
                p.render_widget()
                p.send_alerts()
                p.first_render_complete = true
                for _, w in ipairs(p.instances) do
                    w:show_trigger()
                end
                collectgarbage("collect")
            else
                naughty.notification {
                    title = "Couldn't decode Weather data",
                    message = "Curl returned: " .. out,
                    urgency = "critical",
                    app_name = "Awesome WeatherWidget"
                }
            end
        else
            naughty.notification {
                message = err,
                title = "Error pulling weather data",
                urgency = "critical",
                app_name = "Awesome WeatherWidget"
            }
        end
    end)
end

p.fetch_timer = gears.timer {
    timeout = 900,
    callback = function ()
        p.start_render()
    end
}

m.init = function (bar)
    ---@class WeatherWidget : PopupWidget
    ---@field public show_trigger function
    local WeatherWidget = PopupBase{
        widget = wibox.widget {
            widget = wibox.container.margin,
            margins = dpi(5),
            setmetatable({}, {__index = p.widget}),
        },
        trigger = p.trigger,
        anchor = "right"
    }

    WeatherWidget:register_bar(bar)
    -- hold table of references for updates
    table.insert(p.instances, setmetatable({}, {__index = WeatherWidget}))

    if not p.fetch_timer.started then
        p.fetch_timer:start()
    end

    if p.first_render_complete then
        WeatherWidget:show_trigger()
    else
        p.start_render()
    end
    return WeatherWidget
end

return setmetatable(m, {__call = m.init})
