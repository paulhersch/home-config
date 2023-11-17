local wibox = require "wibox"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local lgi = require "lgi"
local Gio = lgi.Gio
local Gtk = lgi.require("Gtk", "3.0")
local min = math.min
local gears = require "gears"
local awful = require "awful"
-- this requires you to use the following plugin
-- https://github.com/swarn/fzy-lua
-- i have it installed via nix, so this would have to be edited to make it work on other distros
local fzy = require "fzy"
local helpers = require "helpers"
-- widget wrapper for unified ui
local Description = require("ui.components.container").description

local P = {
    data = {},
    max_entry_count = 9
}
local M = {}

local app_info = Gio.AppInfo
local icon_theme = Gtk.IconTheme.get_default()

P.main_template = {
    id = 'grid',
    layout = wibox.layout.grid,
    homogeneous = true,
    forced_num_cols = 1,
    forced_num_rows = 10,
    expand = true,
    vertical_spacing = dpi(5),
}

P.replace_with_escapes = function(text)
    if text then
        text = text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub("'", "&#39;")
    end
    return text
end

P.entry_callbacks = {}
P.entry_callbacks.onclick = function (self, _, _, b)
    if b == awful.button.names.LEFT then
        awful.screen.focused().popup_launcher_widget:stop_search()
        self:launch()
    end
end
P.entry_callbacks.on_hover = function (self, _)
    local s = awful.screen.focused()
    P.data[s].widget:__reset_highlight()
    self.bg = beautiful.bg_2
    --hacky way of retriving current widget position
    P.data[s].current_hl_index = P.data[s].widget
        :get_children_by_id("grid")[1]
        :get_widget_position(self).row
end

--entries need to be cached for every widget instance or highlights will be messy
---Entries of the launcher
---@return table Entries every entry is a table with widget, appinfo and appname
P.get_entries = function()
    local entries = {}
    for _, app in ipairs(app_info.get_all()) do
        if app:should_show() then
            -- fetch data
            local name = P.replace_with_escapes(app:get_name())
            local desc = app:get_description()

            local icon
            local app_icon = app:get_icon()
            if app_icon then
                local pathorname = app_icon:to_string()
                if pathorname then
                    if string.find(pathorname, "/") then --Icon names dont contain slashes
                        icon = pathorname
                    else
                        local icon_info = icon_theme:lookup_icon(pathorname, dpi(48), 0)
                        if icon_info then
                            local path = icon_info:get_filename()
                            if path then
                                icon = path
                            end
                        end
                    end
                end
            end

            --widget instance
            local widget = Description {
                margin = dpi(5),
                widget = {
                    layout = wibox.layout.align.horizontal,
                    {
                        widget = wibox.container.margin,
                        margins = dpi(5),
                        {
                            id = "icon",
                            widget = wibox.widget.imagebox,
                            shape = beautiful.theme_shape,
                            valign = 'center',
                            halign = 'center',
                            image = icon,
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
                                markup = "<span>" .. name .. "</span>",
                                widget = wibox.widget.textbox,
                                font = beautiful.font .. " 12",
                                forced_height = beautiful.get_font_height(beautiful.font .. " 12")
                            },
                            desc and {
                                id = "description",
                                widget = wibox.widget.textbox,
                                font = beautiful.font .. " 10",
                                markup = "<span font_style='italic' foreground='" .. beautiful.gray .. "'>" .. P.replace_with_escapes(desc) .. "</span>"
                            } or nil,
                        }
                    },
                    wibox.widget.base.empty_widget()
                },
                bg = beautiful.bg_1,
                border_width = 0
            }

            -- data for launch
            widget.appinfo = app
            function widget:launch()
                self.appinfo:launch()
            end

            helpers.pointer_on_focus(widget)
            -- connect signals
            widget:connect_signal("mouse::enter", P.entry_callbacks.on_hover)
            widget:connect_signal("button::click", P.entry_callbacks.onclick)

            local cmd = app:get_commandline()

            -- search by display appname and cmd
            widget.search_params = { string.lower(name) }
            if cmd then table.insert(widget.search_params, string.lower(cmd)) end

            entries[#entries+1] = widget
        end
    end
    table.sort(entries, function (a,b)
        --search param 1 is always the name
        return a.search_params[1] < b.search_params[1]
    end)
    return entries
end

M.init = function(s)
    -- entry cache, doesnt matter that much if shared between instances
    -- (unless you do weird stuff)
    if not P.data.entries then
        P.data.entries = P.get_entries()
    end

    -- data for widget on screen s
    P.data[s] = {}
    P.data[s].widget = wibox.widget(P.main_template)

    local entry_grid = setmetatable({}, {
        __index = P.data[s].widget,
        __newindex = function (_, k, v)
            P.data[s].widget[k] = v
        end
    }) -- functions cant be declared on tables with [index]

    local promptwidget = Description {
        margin = dpi(5),
        widget = {
            layout = wibox.layout.align.horizontal,
            expand = "inside",
            {
                widget = wibox.container.margin,
                margins = dpi(5),
                {
                    widget = wibox.widget.imagebox,
                    image = gears.color.recolor_image(gears.filesystem.get_configuration_dir() .. "/assets/materialicons/search.svg", beautiful.fg_normal),
                    valign = 'center',
                    halign = 'center',
                }
            },
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
                    markup = "<span font_style='italic'>search apps</span>",
                    widget = wibox.widget.textbox,
                    forced_width = dpi(1000),
                }
            },
            wibox.widget.base.make_widget(),
            buttons = {
                awful.button{
                    modifiers = {},
                    button = awful.button.names.LEFT,
                    on_press = function ()
                        entry_grid:start_search(false, nil)
                    end
                }
            }
        },
        bg = beautiful.bg_2
    }

    entry_grid:add_widget_at(promptwidget, P.max_entry_count + 1, 1, 1, 1)

    local prompttext = promptwidget:get_children_by_id("prompttext")[1]
    helpers.textcursor_on_focus(prompttext)

    P.data[s].current_hl_index = P.max_entry_count

    function entry_grid:stop_search()
        awful.keyboard.emulate_key_combination({}, "Escape")
        self:__reset_highlight()
    end

    function entry_grid:__reset_highlight()
        local prev_hl = entry_grid:get_widgets_at(P.data[s].current_hl_index, 1, 1, 1)
        if prev_hl then prev_hl[1].bg = beautiful.bg_1 end
    end

    function entry_grid:__reset_all_highlights()
        for _, widget in ipairs(P.data.entries) do
            widget.bg = beautiful.bg_1
        end
    end

    ---@param check_valid function function to check if select function can be run
    ---@param diff integer the selected_entry diff upon running select
    function entry_grid:__select_helper(check_valid, diff)
        if check_valid(P.data[s].current_hl_index) then
            local new_hl = entry_grid:get_widgets_at(P.data[s].current_hl_index + diff, 1, 1, 1)
            if new_hl then
                self:__reset_highlight()
                P.data[s].current_hl_index = P.data[s].current_hl_index + diff
                new_hl[1].bg = beautiful.bg_2
            end
        end
    end

    function entry_grid:select_down()
        self:__select_helper(function (index)
            return index < P.max_entry_count
        end, 1)
    end

    function entry_grid:select_up()
        self:__select_helper(function (index)
            return index > 1
        end, -1)
    end

    function entry_grid:__reset_search()
        prompttext:set_markup_silently("<span font_style='italic'>search apps</span>")
        for i = 1, P.max_entry_count, 1 do
            entry_grid:remove_widgets_at(P.max_entry_count + 1 - i, 1, 1, 1)
            entry_grid:add_widget_at(P.data.entries[i], P.max_entry_count + 1 - i, 1, 1, 1)
        end
        P.data[s].current_hl_index = P.max_entry_count
        entry_grid:get_widgets_at(P.data[s].current_hl_index, 1, 1, 1)[1].bg = beautiful.bg_2
    end

    function entry_grid:search_entries(filter)
        self:__reset_highlight()

        local filtered = {}
        for _, entry in ipairs(P.data.entries) do
            for _, attr in ipairs(entry.search_params) do
                if fzy.has_match(filter, attr, false) then
                    table.insert(filtered, entry)
                    break
                end
            end
        end
        -- some weighting on the match results (to sort matches) 
        local function calc_filter_score(entry)
            local filter_res = fzy.filter(filter, entry.search_params, false)
                local sum = 0.0
                for _, scoring in ipairs(filter_res) do
                    sum = sum + scoring[3]
                end
            return sum
        end

        -- save the score to not call this all the time
        for _, entry in ipairs(filtered) do
            entry.match_score = calc_filter_score(entry)
        end

        -- sort the filtered entries
        table.sort(filtered, function (a, b)
            return a.match_score > b.match_score
        end)

        -- this would usually be done via reset (in a layout container),
        -- but the prompt is part of the grid so not possible
        for i = 1, P.max_entry_count, 1 do
            entry_grid:remove_widgets_at(i, 1, 1, 1)
        end

        for i = 1, min(#filtered, P.max_entry_count), 1 do
            entry_grid:add_widget_at(filtered[i], P.max_entry_count + 1 - i, 1, 1, 1)
            if i == 1 then
                filtered[1].bg = beautiful.bg_2
                P.data[s].current_hl_index = P.max_entry_count
            end
        end

    end

    ---@param hide_after_search boolean if the launcher wibox should be hidden after running the applauncher
    ---@param popup? LauncherPopup Popup calling method if hide_after_search is set
    function entry_grid:start_search(hide_after_search, popup)
        promptwidget.bg = beautiful.bg_3
        self:__reset_highlight()
        entry_grid:get_widgets_at(P.data[s].current_hl_index, 1, 1, 1)[1].bg = beautiful.bg_2

        awful.prompt.run {
            textbox = prompttext,
            bg_cursor = beautiful.fg_normal,
            font = beautiful.font,
            hooks = {
                {{}, "Up", function (cmd)
                    self:select_up()
                    return cmd, true
                end},
                {{}, "Down", function (cmd)
                    self:select_down()
                    return cmd, true
                end},
                {{}, "Return",function ()
                    local sel = entry_grid:get_widgets_at(P.data[s].current_hl_index, 1, 1, 1)
                    if sel then
                        self:__reset_highlight()
                        sel[1]:launch()
                    end
                end}
            },
            changed_callback = function (cmd)
                entry_grid:search_entries(cmd)
                collectgarbage("collect")
            end,
            done_callback = function ()
                self:__reset_search()
                --resetting only the current highlight can cause buggy behaviour here
                --self:__reset_all_highlights()
                self:__reset_highlight()
                promptwidget.bg = beautiful.bg_2
                if hide_after_search then
                    if popup then popup:hide() end
                end
            end
        }
    end

    function entry_grid:is_active()
        return prompttext.text ~= "search apps"
    end

    -- initial fill
    entry_grid:__reset_search()
    return entry_grid
end

return M
