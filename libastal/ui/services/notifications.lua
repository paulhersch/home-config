--
-- Added boilerplate to my boilerplate so that the
-- widgets have an even simpler interface
--

local lgi = require "lgi"
local Notifd = lgi.require("AstalNotifd")

local Variable = require("astal.variable")
local timeout = require("astal.time").timeout

local notifd_instance = Notifd.get_default()

-- object with data
local Service = {
    shown = Variable.new({}),
    saved = Variable.new({}),
    dnd = false
}

local saved_counter = 0

-- remove all currently shown notifications
function Service:clear()
    self.shown:set({})
end

local function _get_from_shown(id)
    local shown = Service.shown:get()
    for i, item in pairs(shown) do
        if item.id == id then
            return i, item
        end
    end
    return -1, nil
end

local function _delete_from_shown_if_exists(id)
    local pos, item = _get_from_shown(id)
    if item then
        table.remove(Service.shown:get(), pos)
        Service.shown.variable:emit_changed()
    end
    return item
end

-- true if notification should be saved
local function _filter_saved(notification)
    -- print(notification.app_name)
    -- never save the song stuff
    if notification.app_name == "Spotify" then
        return false
    end

    return true
end

local function _copy_to_saved(notification)
    -- check for the filters first
    if not _filter_saved(notification) then
        return
    end

    local copy = {
        time = notification.time,
        app_name = notification.app_name,
        app_icon = notification.app_icon,
        summary = notification.summary,
        body = notification.body,
        image = notification.image,
        id = saved_counter
    }
    -- keep track of message count, use counter as id
    saved_counter = saved_counter + 1
    table.insert(Service.saved:get(), copy)
    Service.saved.variable:emit_changed()
end

-- remove copy of message, return message if found, otherwise nil
function Service:delete_from_saved(id)
    -- print(id)
    -- binary search over items
    local saved_copy = Service.saved:get()

    local left = 1
    local right = #saved_copy
    local middle = math.floor((left + right) / 2)

    while (right >= left) do
        -- hit?
        if saved_copy[middle].id == id then
            local item = table.remove(saved_copy, middle)
            Service.saved.variable:emit_changed()
            return item
        end

        if saved_copy[middle].id < id then
            -- go right
            left = middle + 1
        else
            -- go left
            right = middle - 1
        end

        middle = math.floor((left + right) / 2)
    end

    collectgarbage("step")

    return nil
end

-- local function _copy_to_saved_if_exists(id)
--     local _, notification = _get_from_shown(id)
--     if notification then
--         _copy_to_saved(notification)
--     end
-- end

-- notifd settings
notifd_instance:set_ignore_timeout(false)
local default_timeout = 3000

function notifd_instance:on_notified(id)
    local notification = notifd_instance:get_notification(id)

    -- this should usually cover all bases, if closing is done as expected
    function notification:on_resolved(reason, _)
        if reason == Notifd.ClosedReason.EXPIRED then
            _copy_to_saved(notification)
        end
        _delete_from_shown_if_exists(self.id)
    end

    if Service.dnd then
        _copy_to_saved(notification)
        notification:dismiss()
    else
        table.insert(Service.shown:get(), notification)
        Service.shown.variable:emit_changed()

        -- added part to cover timeout = -1 and edgecases where notifications are resolved
        -- before this timeout runs
        -- somewhere in here is a weird bug that happens when notifications get spammed
        if notification.expire_timeout == -1 then
            timeout(default_timeout, function()
                -- if it still exists, dismiss it after copying the data
                local _, notification_maybe = _get_from_shown(id)
                if notification_maybe then
                    _copy_to_saved(notification)
                    notification:dismiss() -- end notification lifecycle
                end
            end)
        end
    end
end

return Service
