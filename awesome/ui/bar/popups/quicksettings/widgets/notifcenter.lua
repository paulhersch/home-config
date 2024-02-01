local wibox = require "wibox"
local naughty = require "naughty"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local gears = require "gears"
local container = require("ui.components.container")
local client = client

local M = {}

M.bar_indic_notif = function()
    require "ui.bar.popups.quicksettings".show_notif()
end

M.bar_indic_no_notif = function()
    require "ui.bar.popups.quicksettings".hide_notif()
end

M.main_widget = wibox.widget {
    id = "notifcenter_layout",
    layout = wibox.layout.fixed.vertical,
    spacing = dpi(5)
}

M.main_widget.__remove_widgets_old = M.main_widget.remove_widgets
function M.main_widget:remove_widgets(...)
    self:__remove_widgets_old(...)
    if #self:get_children() == 0 then
        M.bar_indic_no_notif()
    end
end

M.main_widget.__insert_old = M.main_widget.insert
function M.main_widget:insert(index, w)
    self:__insert_old(index, w)
    M.bar_indic_notif()
end

M.add_notif_widget = function (n)
    local appname = n.app_name ~= "" and n.app_name or 'undefined'

    local drawer
    --check if the app already has a drawer thingy
    for _, d in ipairs(M.main_widget:get_children()) do
        if d.title == appname then
            drawer = d
            --move currently used drawer to the top
            M.main_widget:remove_widgets(drawer)
            M.main_widget:insert(1, drawer)
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
                for _, c in ipairs(M.main_widget:get_children()) do
                    if c.title == appname then
                        M.main_widget:remove_widgets(c)
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
                M.main_widget:remove_widgets(self)
            end
        end

        M.main_widget:insert(1, drawer)
    end

    local title = gears.string.xml_escape(n.title)
    if #title > 40 then
        ---@diagnostic disable-next-line: param-type-mismatch, need-check-nil
        title = string.sub(title, 1, 40)
        title = title .. "..."
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

    w:add_button_widget(
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

-- Telegram does weird stuff with their notification strings and it causes issues???
M.blacklisted_appnames = { "Spotify", "NetworkManager", "Netzwerk-Manager-Applet", "Telegram Desktop" }
M.blacklisted_titles = { "battery low!" }

M.shouldnt_add = function (n)
    for _, an in ipairs(M.blacklisted_appnames) do
        if an == n.app_name then return true end
    end
    for _, nt in ipairs(M.blacklisted_titles) do
        if nt == n.title then return true end
    end
    return false
end

-- some programs have a different Window Class then what they report for
-- notifications. To give them the same name so that the autodeletion
-- works i am replacing the names
M.app_class_nappname_map = {
    ["TelegramDesktop"] = "Telegram Desktop"
}

naughty.connect_signal("request::display", function(n)
    -- if notification is sent from currently focused client dont do anything
    if client.focus and n.app_name then
        if (
            string.lower(client.focus.class) == n.app_name
            or M.app_class_nappname_map[string.lower(client.focus.class)] == n.app_name
        ) then
            return
        end
    end

    -- dont add if blacklists apply or sending client is currently focused
    if (not M.shouldnt_add(n)) then
        M.add_notif_widget(n)
    end
end)

-- autodelete notifications of clients that are now being focused
client.connect_signal("property::active", function (c)
    -- most apps report their name via class so that should be alright
    if c and c.class then
        local cname = string.lower(c.class) or nil
        for _, entry in ipairs(M.main_widget:get_children()) do
            if string.lower(entry.title) == cname or string.lower(entry.title) == M.app_class_nappname_map[cname] then
                M.main_widget:remove_widgets(entry)
            end
        end
    end
end)

return M.main_widget
