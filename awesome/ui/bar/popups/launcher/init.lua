local wibox = require "wibox"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local helpers = require "helpers"
local gears = require "gears"
local awful = require "awful"
local settings = require "settings"
local searchwidget = require "ui.bar.popups.launcher.search"
local container = require("ui.components.container")
local button = container.button
local description = container.description
local PopupBase = require("ui.bar.popups.base").new

local m = {}

local function create_power_button(imagename, on_press, color)
    local widget = button.new {
        widget = {
            widget = wibox.widget.imagebox,
            image = color ~= nil and gears.color.recolor_image(
                gears.filesystem.get_configuration_dir() .. "/assets/materialicons/" .. imagename,
                color) or imagename,
        },
        left = {
            on_click = on_press
        }
    }
    return widget
end

local function create_launcher_widget(s)
    return searchwidget.init(s)
end

---@return LauncherPopup
m.init = function (bar)
    local s = bar.screen
    local w, h = dpi(450), dpi(600)
    s.searchWidget = create_launcher_widget(s)

    ---@class LauncherPopup : PopupWidget
    ---@field show_and_run function Show Popup and Run prompt
    ---@field hide function Hide Popup (used by widget)
    ---@field launcherWidget any The real launcher Widget
    ---@diagnostic disable-next-line: assign-type-mismatch
    LauncherPopup = PopupBase {
        anchor = "left",
        trigger = gears.filesystem.get_configuration_dir() .. "assets/Nix.svg",
        widget = wibox.widget {
            widget = wibox.container.margin,
            margins = dpi(10),
            forced_height = h,
            forced_width = w,
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(10),
                {
                    widget = wibox.container.constraint,
                    width = w - dpi(90),
                    description {
                        widget = setmetatable({}, {__index = s.searchWidget}),
                        margin = dpi(10),
                    }
                },
                {
                    layout = wibox.layout.fixed.vertical,
                    spacing = dpi(10),
                    {
                        widget = wibox.container.margin,
                        margin = dpi(5),
                        {
                            widget = wibox.widget.imagebox,
                            image = helpers.crop_surface(1, gears.surface.load(os.getenv("HOME") .. "/.face")),
                        }
                    },
                    -- {
                    --     widget = wibox.container.margin,
                    --     margin = dpi(5),
                    --     {
                    --         layout = wibox.layout.fixed.vertical,
                    --         spacing = dpi(5),
                    --         {
                    --             widget = wibox.widget.imagebox,
                    --             image = get_gtk_icon("system-file-manager")
                    --         },
                    --         {
                    --             widget = wibox.widget.imagebox,
                    --             image = get_gtk_icon("applications-internet")
                    --             -- create_power_button(get_gtk_icon("applications-internet"), function ()
                    --             --     awful.spawn("")
                    --             -- end, nil)
                    --             -- 
                    --         }
                    --     }
                    -- },
                    {
                        widget = wibox.container.place,
                        valign = 'bottom',
                        halign = 'center',
                        {
                            layout = wibox.layout.fixed.vertical,
                            spacing = dpi(5),
                            create_power_button("poweroff.svg", function ()
                                awful.spawn("poweroff")
                            end, beautiful.red),
                            create_power_button("restart.svg", function ()
                                awful.spawn("reboot")
                            end, beautiful.green),
                            create_power_button("suspend.svg", function ()
                                awful.spawn("systemctl suspend")
                            end, beautiful.cyan),
                            create_power_button("lock.svg", function ()
                                awful.spawn("i3lock-color -c " .. string.sub(beautiful.bg_normal,2,7) .. "60 --greeter-text='enter password' -efk --time-pos='x+w-100:y+h-50'")
                            end, beautiful.yellow),
                            create_power_button("logout.svg", function ()
                                awful.spawn("pkill awesome")
                            end, beautiful.blue),
                        }
                    }
                },
            }
        }
    }

    -- register in screen
    s.launcher = LauncherPopup
    LauncherPopup:register_bar(bar)
    LauncherPopup:show_trigger()

    function LauncherPopup:show_and_run()
        self:__show_popup()
        s.searchWidget:start_search(true, self)
    end

    function LauncherPopup:hide()
        s.searchWidget:stop_search()
        self:__hide_popup()
    end

    return LauncherPopup
end

m.use_launcher = function ()
    local s = awful.screen.focused()
    s.launcher:show_and_run()
end

awful.keyboard.append_global_keybinding(
    awful.key {
        modifiers = {settings.get("modkey")},
        key = "d",
        on_press = m.use_launcher
    }
)

return setmetatable(m, {__call = m.init})
