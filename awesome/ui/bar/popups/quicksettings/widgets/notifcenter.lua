local wibox = require "wibox"
local awful = require "awful"
local naughty = require "naughty"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local gears = require "gears"
local settings  = require "settings"
local helpers = require "helpers"
local container = require("ui.components.container")
local client = client

local iconsdir = gears.filesystem.get_configuration_dir() .. "assets/titlebarbuttons/"
local mat_icons = gears.filesystem.get_configuration_dir() .. "assets/materialicons/"

local notif_enabled_icon = gears.color.recolor_image(mat_icons .. "notifications_active.svg", beautiful.fg_focus)
local notif_disabled_icon = gears.color.recolor_image(mat_icons .. "notifications_off.svg", beautiful.fg_focus)
local sound_enabled_icon = gears.color.recolor_image(mat_icons .. "volume_up.svg", beautiful.fg_focus)
local sound_disabled_icon = gears.color.recolor_image(mat_icons .. "volume_off.svg", beautiful.fg_focus)

local function bar_indic_notif()
    require "ui.bar.popups.quicksettings".show_notif()
end

local function bar_indic_no_notif()
    require "ui.bar.popups.quicksettings".hide_notif()
end

local main_widget = wibox.widget {
    layout = wibox.layout.fixed.vertical,
    spacing = dpi(5)
}

-- some programs have a different Window Class then what they report for
-- notifications. To give them the same name so that the autodeletion
-- works i am replacing the names
local app_name_replacements = {
    ["Telegram Desktop"] = "TelegramDesktop"
}

local function add_notif_widget(n)
    local appname = n.app_name ~= "" and (app_name_replacements[n.app_name] or n.app_name) or 'undefined'

    local drawer
    --check if the app already has a drawer thingy
    for _, d in ipairs(main_widget:get_children()) do
        if d.title == appname then
            drawer = d
            --move currently used drawer to the top
            main_widget:remove_widgets(drawer)
            main_widget:insert(1, drawer)
            break
        end
    end

    --if there are no recent notifications from the app we create a new drawer for them and add button magic
    if not drawer then
        drawer = container.details {
            title = appname,
            open = false,
            deleteable = true,
            delete_callback = function ()
                for _, c in ipairs(main_widget:get_children()) do
                    if c.title == appname then
                        main_widget:remove_widgets(c)
                        break
                    end
                end
            end,
            bg = beautiful.bg_1,
            widget = wibox.widget {
                    layout = wibox.layout.fixed.vertical,
                    spacing = dpi(2)
            }
        }

        function drawer:add_notif(widget)
            self:get_children()[1]:add(widget)
        end

        function drawer:remove_notif(widget)
            self:get_children()[1]:remove_widgets(widget)
            if #self:get_children()[1].children == 0 then
                main_widget:remove_widgets(self)
            end
            if #main_widget:get_children() == 0 then
                bar_indic_no_notif()
            end
        end

        main_widget:insert(1, drawer)
    end

    local title = n.title
    if #title >= 40 then
        title = string.gsub(title, title:sub(40, #title), "...")
    end

    local w = container.description {
        description = title,
        bg = beautiful.bg_2,
        widget = wibox.widget {
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(5),
            n.icon and {
                widget = wibox.container.constraint,
                width = dpi(40),
                {
                    widget = wibox.widget.imagebox,
                    image = n.icon
                }
            },
            {
                widget = wibox.widget.textbox,
                markup = string.format("<i>%s</i>", gears.string.xml_escape(n.message))
            }
        }
    }

    w:add_button(
        container.button {
            widget = {
                widget = wibox.widget.textbox,
                text = "x"
            },
            left = {
                on_release = function ()
                    drawer:remove_notif(w)
                    collectgarbage("collect")
                end
            }
        }
    )

    drawer:add_notif(w)
end

local blacklisted_appnames = { "Spotify", "NetworkManager" }
local blacklisted_titles = { "battery low!" }

local function shouldnt_add (n)
    for _, an in ipairs(blacklisted_appnames) do
        if an == n.app_name then return true end
    end
    for _, nt in ipairs(blacklisted_titles) do
        if nt == n.title then return true end
    end
    return false
end

naughty.connect_signal("request::display", function(n)
    -- if notification is sent from currently focused client dont do anything
    if client.focus and n.app_name and (string.lower(client.focus.class) == n.app_name) then
        return
    end

    -- dont add if blacklists apply or sending client is currently focused
    if (not shouldnt_add(n)) then
        add_notif_widget(n)
        bar_indic_notif()
    end
end)

client.connect_signal("property::active", function (c)
    -- sometimes c is nil???
    -- most apps report their name via class so that should be alright
    if c then
        local cname = string.lower(c.class) or nil
        for _, entry in ipairs(main_widget:get_children()) do
            if string.lower(entry.title) == cname then
                main_widget:remove_widgets(entry)
                if #main_widget:get_children() == 0 then bar_indic_no_notif() end
            end
        end
    end
end)

return main_widget -- notifbox
