local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local cairo = require("lgi").cairo
local json = require("rapidjson")

local math = math
local table = table
local unpack = unpack or table.unpack
local settings = require("settings")
local container = require("ui.components.container")
local Description = container.description
local Button = container.button

local PopupBase = require("ui.bar.popups.base").new

local weathericon_path = gears.filesystem.get_configuration_dir() .. "assets/weathericons/"

local M = {}
local P = {
    ---@type WeatherWidget[]
    current_data = {},
    trigger = wibox.widget {
        widget = wibox.container.background,
        {
            id = "trigger_layout",
            layout = wibox.layout.fixed.horizontal,
            forced_height = dpi(20),
            spacing = dpi(5),
            {
                id = "icon",
                widget = wibox.widget.imagebox,
                image = gears.color.recolor_image(weathericon_path .. "01d.svg", beautiful.fg_normal),
                forced_width = dpi(20),
            },
        }
    },
    alert_symbol = wibox.widget {
        widget = wibox.widget.imagebox,
        image = gears.color.recolor_image(
            weathericon_path .. "alert.svg",
            beautiful.fg_normal
        ),
        forced_width = dpi(20)
    },
    first_render_complete = false,
    width = dpi(450),
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
P.draw_wind_arrow = function(cr, w, h, rotation)
    local dist_wings = math.floor(w/5)
    local w2, h2 = math.floor(w/2), math.floor(h/2)
    local offset = math.ceil(h/7)
    cr:set_line_width(dpi(1))
    cr:translate(w2, h2)
    cr:rotate(math.rad(rotation))
    cr:set_source_rgba(gears.color.parse_color(beautiful.fg_normal))
    cr:move_to(0, -h2+offset)
    cr:line_to(dist_wings, h2-offset)
    cr:line_to(0, h2-dist_wings)
    cr:line_to(-dist_wings, h2-offset)
    cr:line_to(0, -h2+offset)
    cr:stroke()
end

P.gradient = function (x1, x2, y1, y2)
    return (y2-y1)/(x2-x1)
end

---@return any widget displaying the current weather
P.render_current_weather = function ()
    local current_weather = P.current_data.current
    local layout = wibox.widget {
            id = "inner_layout",
            layout = wibox.layout.grid,
            homogeneous = true,
            expand = true,
            spacing = dpi(5),
            forced_num_cols = 4,
            forced_num_rows = 2,
    }
    layout:add_widget_at(wibox.widget {
        widget = wibox.container.place,
        valign = "center",
        halign = "center",
        {
            widget = wibox.widget.imagebox,
            image = gears.color.recolor_image(
                weathericon_path .. current_weather.weather[1].icon .. ".svg",
                beautiful.fg_normal
            ),
            forced_height = P.current_weather.height*4/5,
            forced_width = P.current_weather.height*4/5
        }
    }, 1, 1, 2, 1)
    layout:add_widget_at(wibox.widget {
        widget = wibox.widget.textbox,
        valign = "bottom",
        halign = "left",
        text = string.format("%.1f °C", current_weather.temp),
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
                        P.draw_wind_arrow(cr, w, h, current_weather.wind_deg)
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

P.render_temp_graph = function (cr, w, h)
    local datapoints = {}
    for _, hour in ipairs(P.current_data.hourly) do
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
    cr:set_line_width(dpi(1))
    local dash_pattern = {dpi(6), dpi(4)}

    local function calc_y(temp)
        -- top left coord-system -> target - temp
        -- + min_abs to shift values upwards (cant have negative pixel vals)
        -- + h_offset to put values in middle of target area (otherwise one line would
        -- touch the border)
        return h_target - math.floor((temp+mintemp_abs)*h_factor) + h_offset
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
    -- check if zero has already been added
    local rendered_zero = false
    -- text
    for i = 0, 4, 1 do
        -- shift up because no <0, shift back down
        local temp = ((mintemp_abs+max)*(i/4))-mintemp_abs
        rendered_zero = rendered_zero or temp == 0
        local y = calc_y(temp)
        cr:set_source_rgba(gears.color.parse_color(beautiful.fg_normal))
        cr:move_to(0, y+font_height/2) -- push down so mid is on line
        cr:show_text(string.format("%.1f°C", temp))
        cr:set_source_rgba(gears.color.parse_color(beautiful.gray))
        cr:set_dash(dash_pattern, 1, 0)
        cr:move_to(w_start, y)
        cr:line_to(w_start+w_range, y)
        cr:stroke()
        cr:set_dash({}, 0, 0)
    end

    -- 0 line
    if not rendered_zero then
        cr:set_source_rgba(gears.color.parse_color(beautiful.gray))
        local h_0 = calc_y(0)
        cr:move_to(w_start+1, h_0)
        cr:line_to(w_start + w_range, h_0)
        cr:stroke()
    end

    for i = 0, 4, 1 do
        -- similar to how index above is calculated
        -- max 4/5 so text does not get cut off
        -- also 1 base index things
        local dp_index = math.floor(#graph_datapoints*(i/4))
        local text = graph_datapoints[dp_index == 0 and 1 or dp_index].time
        local extents = cr:text_extents(text)
        local x_pos = math.floor(w_start+w_factor*dp_index)
        -- nibbly things + text
        cr:set_source_rgba(gears.color.parse_color(beautiful.fg_normal))
        cr:move_to(x_pos, h_max)
        cr:line_to(x_pos, h_max+dpi(4))
        cr:stroke()
        cr:move_to(x_pos-extents.width/2, h)
        cr:show_text(text)
        -- dashed lines
        if i > 0 and i < 4 then
            cr:set_source_rgba(gears.color.parse_color(beautiful.gray))
            cr:set_dash(dash_pattern, 1, 0)
            cr:move_to(x_pos, h_max)
            cr:line_to(x_pos, 0)
            cr:stroke()
            cr:set_dash({}, 0, 0)
        end
    end

    cr:set_line_width(dpi(2))
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

P.render_forecast = function ()
    return wibox.widget {
        widget = wibox.container.background,
        forced_height = P.forecast.height,
        bgimage = function (_, cr, w, h)
            P.render_temp_graph(cr, w, h)
        end
    }
end

P.render_alerts = function ()
    local alerts = {}
    for _, alert in ipairs(P.current_data.alerts) do
        table.insert(alerts, {
            layout = wibox.layout.fixed.vertical,
            spacing = dpi(5),
            {
                widget = wibox.widget.textbox,
                markup = string.format(
                    "<b>%s</b> <i>%s - %s</i>",
                    gears.string.xml_escape(alert.event),
                    os.date("%d.%m %H:%M", alert.start),
                    -- end will even be recognized as control string when its part of the table
                    os.date("%d.%m %H:%M", alert["end"])
                ),
                font = beautiful.font .. " 11",
            },
            {
                widget = wibox.widget.textbox,
                font = beautiful.font .. " 10",
                markup = "<span>" .. gears.string.xml_escape(alert.description) .. "</span>",
                wrap = "word"
            }
        })
    end

    local layout = wibox.widget {
        id = "inner_layout",
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(10),
    }
    layout:add(unpack(alerts))

    return Description {
        description = "Alerts",
        widget = layout,
        bg = beautiful.bg_1
    }
end

P.current_group = Description {
    widget = {
        widget = wibox.container.background,
        forced_height = P.current_weather.height,
        bg = beautiful.bg_2,
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
    description = "Current",
    group_buttons = {
        Button.new {
            margins = dpi(2),
            border_radius = dpi(9), -- default group margin thingy
            widget = {
                widget = wibox.container.margin,
                margins = {left=dpi(10), right=dpi(10)},
                {
                    widget = wibox.widget.textbox,
                    text = "update"
                }
            },
            left = {
                on_release = function ()
                    P.update_widget()
                    P.update_timer:again()
                end
            }
        }
    }
}

P.forecast_group = Description {
    widget = {
        widget = wibox.container.background,
        bg = beautiful.bg_2,
        forced_height = P.forecast.height,
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
    description = "Forecast"
}


P.widget = wibox.widget {
    layout = wibox.layout.fixed.vertical,
    spacing = dpi(10),
    P.current_group,
    P.forecast_group
}

P.render_widget = function ()
    P.current_group.children = {P.render_current_weather()}
    P.forecast_group.children = {P.render_forecast()}
    if P.current_data.alerts then
        if #P.widget.children == 3 then
            P.widget:set(3, P.render_alerts())
        end
        if #P.widget.children == 2 then
            P.widget:add(P.render_alerts())
        end
    else
        if #P.widget.children == 3 then
            P.widget:remove(3)
        end
    end
end

P.update_trigger = function ()
    local current_weather = P.current_data.current.weather[1]
    local trigger_layout = P.trigger:get_children_by_id("trigger_layout")[1]
    local trigger_icon = P.trigger:get_children_by_id("icon")[1]

    local alert_index = trigger_layout:index(P.alert_symbol)

    trigger_icon.image = gears.color.recolor_image(
        weathericon_path .. current_weather.icon .. ".svg",
        beautiful.fg_normal
    )
    if P.current_data.alerts then
        if not alert_index then
            trigger_layout:add(P.alert_symbol)
        end
    else
        if alert_index then
            trigger_layout:remove_widgets(P.alert_symbol)
        end
    end
end

P.update_widget = function ()
    local cmd = "curl 'https://api.openweathermap.org/data/2.5/onecall?lat=".. settings.get("weather.lat")
        .. "&lon=" .. settings.get("weather.lon")
        .. "&appid=" .. settings.get("weather.apikey")
        .. "&units=" .. settings.get("weather.units")
        .. "&exclude=minutely,daily&lang=de" .. "'"
    awful.spawn.easy_async(cmd, function (out, err, _, exitcode)
        if exitcode == 0 then
            local success, data = pcall(json.decode, out)
            if success then
                P.current_data = data
                P.update_trigger()
                P.render_widget()
                P.first_render_complete = true
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

P.update_timer = gears.timer {
    timeout = 900,
    callback = P.update_widget
}

M.init = function (bar)
    ---@class WeatherWidget : PopupWidget
    ---@field public show_trigger function
    local WeatherWidget = PopupBase{
        widget = wibox.widget {
            widget = wibox.container.margin,
            margins = dpi(10),
            {
                widget = wibox.container.constraint,
                width = P.width,
                strategy = "exact",
                setmetatable({}, {__index = P.widget}),
            }
        },
        trigger = P.trigger,
        anchor = "right"
    }

    WeatherWidget:register_bar(bar)
    WeatherWidget:show_trigger()

    if not P.update_timer.started then
        P.update_widget()
        P.update_timer:start()
    end

    return WeatherWidget
end

return setmetatable(M, {__call = M.init})
